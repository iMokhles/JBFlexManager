//
//  IMLEXNetworkRecorder.m
//  Flipboard
//
//  Created by Ryan Olson on 2/4/15.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXNetworkRecorder.h"
#import "IMLEXNetworkCurlLogger.h"
#import "IMLEXNetworkTransaction.h"
#import "IMLEXUtility.h"
#import "IMLEXResources.h"
#import "NSUserDefaults+IMLEX.h"

NSString *const kIMLEXNetworkRecorderNewTransactionNotification = @"kIMLEXNetworkRecorderNewTransactionNotification";
NSString *const kIMLEXNetworkRecorderTransactionUpdatedNotification = @"kIMLEXNetworkRecorderTransactionUpdatedNotification";
NSString *const kIMLEXNetworkRecorderUserInfoTransactionKey = @"transaction";
NSString *const kIMLEXNetworkRecorderTransactionsClearedNotification = @"kIMLEXNetworkRecorderTransactionsClearedNotification";

NSString *const kIMLEXNetworkRecorderResponseCacheLimitDefaultsKey = @"com.IMLEX.responseCacheLimit";

@interface IMLEXNetworkRecorder ()

@property (nonatomic) NSCache *responseCache;
@property (nonatomic) NSMutableArray<IMLEXNetworkTransaction *> *orderedTransactions;
@property (nonatomic) NSMutableDictionary<NSString *, IMLEXNetworkTransaction *> *requestIDsToTransactions;
@property (nonatomic) dispatch_queue_t queue;

@end

@implementation IMLEXNetworkRecorder

- (instancetype)init {
    self = [super init];
    if (self) {
        self.responseCache = [NSCache new];
        NSUInteger responseCacheLimit = [[NSUserDefaults.standardUserDefaults
            objectForKey:kIMLEXNetworkRecorderResponseCacheLimitDefaultsKey] unsignedIntegerValue
        ];
        
        // Default to 25 MB max. The cache will purge earlier if there is memory pressure.
        self.responseCache.totalCostLimit = responseCacheLimit ?: 25 * 1024 * 1024;
        [self.responseCache setTotalCostLimit:responseCacheLimit];
        
        self.orderedTransactions = [NSMutableArray new];
        self.requestIDsToTransactions = [NSMutableDictionary new];
        self.hostBlacklist = NSUserDefaults.standardUserDefaults.IMLEX_networkHostBlacklist.mutableCopy;

        // Serial queue used because we use mutable objects that are not thread safe
        self.queue = dispatch_queue_create("com.IMLEX.IMLEXNetworkRecorder", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

+ (instancetype)defaultRecorder {
    static IMLEXNetworkRecorder *defaultRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultRecorder = [self new];
    });
    
    return defaultRecorder;
}

#pragma mark - Public Data Access

- (NSUInteger)responseCacheByteLimit {
    return self.responseCache.totalCostLimit;
}

- (void)setResponseCacheByteLimit:(NSUInteger)responseCacheByteLimit {
    self.responseCache.totalCostLimit = responseCacheByteLimit;
    [NSUserDefaults.standardUserDefaults
        setObject:@(responseCacheByteLimit)
        forKey:kIMLEXNetworkRecorderResponseCacheLimitDefaultsKey
    ];
}

- (NSArray<IMLEXNetworkTransaction *> *)networkTransactions {
    __block NSArray<IMLEXNetworkTransaction *> *transactions = nil;
    dispatch_sync(self.queue, ^{
        transactions = self.orderedTransactions.copy;
    });
    return transactions;
}

- (NSData *)cachedResponseBodyForTransaction:(IMLEXNetworkTransaction *)transaction {
    return [self.responseCache objectForKey:transaction.requestID];
}

- (void)clearRecordedActivity {
    dispatch_async(self.queue, ^{
        [self.responseCache removeAllObjects];
        [self.orderedTransactions removeAllObjects];
        [self.requestIDsToTransactions removeAllObjects];
        
        [self notify:kIMLEXNetworkRecorderTransactionsClearedNotification transaction:nil];
    });
}

- (void)clearBlacklistedTransactions {
    dispatch_sync(self.queue, ^{
        self.orderedTransactions = ({
            [self.orderedTransactions IMLEX_filtered:^BOOL(IMLEXNetworkTransaction *ta, NSUInteger idx) {
                NSString *host = ta.request.URL.host;
                for (NSString *blacklisted in self.hostBlacklist) {
                    if ([host hasSuffix:blacklisted]) {
                        return NO;
                    }
                }
                
                return YES;
            }];
        });
    });
}

- (void)synchronizeBlacklist {
    NSUserDefaults.standardUserDefaults.IMLEX_networkHostBlacklist = self.hostBlacklist;
}

#pragma mark - Network Events

- (void)recordRequestWillBeSentWithRequestID:(NSString *)requestID
                                     request:(NSURLRequest *)request
                            redirectResponse:(NSURLResponse *)redirectResponse {
    for (NSString *host in self.hostBlacklist) {
        if ([request.URL.host hasSuffix:host]) {
            return;
        }
    }
    
    // Before async block to stay accurate
    NSDate *startDate = [NSDate date];

    if (redirectResponse) {
        [self recordResponseReceivedWithRequestID:requestID response:redirectResponse];
        [self recordLoadingFinishedWithRequestID:requestID responseBody:nil];
    }

    dispatch_async(self.queue, ^{
        IMLEXNetworkTransaction *transaction = [IMLEXNetworkTransaction new];
        transaction.requestID = requestID;
        transaction.request = request;
        transaction.startTime = startDate;

        [self.orderedTransactions insertObject:transaction atIndex:0];
        [self.requestIDsToTransactions setObject:transaction forKey:requestID];
        transaction.transactionState = IMLEXNetworkTransactionStateAwaitingResponse;

        [self postNewTransactionNotificationWithTransaction:transaction];
    });
}

- (void)recordResponseReceivedWithRequestID:(NSString *)requestID response:(NSURLResponse *)response {
    // Before async block to stay accurate
    NSDate *responseDate = [NSDate date];

    dispatch_async(self.queue, ^{
        IMLEXNetworkTransaction *transaction = self.requestIDsToTransactions[requestID];
        if (!transaction) {
            return;
        }
        
        transaction.response = response;
        transaction.transactionState = IMLEXNetworkTransactionStateReceivingData;
        transaction.latency = -[transaction.startTime timeIntervalSinceDate:responseDate];

        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordDataReceivedWithRequestID:(NSString *)requestID dataLength:(int64_t)dataLength {
    dispatch_async(self.queue, ^{
        IMLEXNetworkTransaction *transaction = self.requestIDsToTransactions[requestID];
        if (!transaction) {
            return;
        }
        
        transaction.receivedDataLength += dataLength;
        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordLoadingFinishedWithRequestID:(NSString *)requestID responseBody:(NSData *)responseBody {
    NSDate *finishedDate = [NSDate date];

    dispatch_async(self.queue, ^{
        IMLEXNetworkTransaction *transaction = self.requestIDsToTransactions[requestID];
        if (!transaction) {
            return;
        }
        
        transaction.transactionState = IMLEXNetworkTransactionStateFinished;
        transaction.duration = -[transaction.startTime timeIntervalSinceDate:finishedDate];

        BOOL shouldCache = responseBody.length > 0;
        if (!self.shouldCacheMediaResponses) {
            NSArray<NSString *> *ignoredMIMETypePrefixes = @[ @"audio", @"image", @"video" ];
            for (NSString *ignoredPrefix in ignoredMIMETypePrefixes) {
                shouldCache = shouldCache && ![transaction.response.MIMEType hasPrefix:ignoredPrefix];
            }
        }
        
        if (shouldCache) {
            [self.responseCache setObject:responseBody forKey:requestID cost:responseBody.length];
        }

        NSString *mimeType = transaction.response.MIMEType;
        if ([mimeType hasPrefix:@"image/"] && responseBody.length > 0) {
            // Thumbnail image previews on a separate background queue
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSInteger maxPixelDimension = UIScreen.mainScreen.scale * 32.0;
                transaction.responseThumbnail = [IMLEXUtility
                    thumbnailedImageWithMaxPixelDimension:maxPixelDimension
                    fromImageData:responseBody
                ];
                [self postUpdateNotificationForTransaction:transaction];
            });
        } else if ([mimeType isEqual:@"application/json"]) {
            transaction.responseThumbnail = IMLEXResources.jsonIcon;
        } else if ([mimeType isEqual:@"text/plain"]){
            transaction.responseThumbnail = IMLEXResources.textPlainIcon;
        } else if ([mimeType isEqual:@"text/html"]) {
            transaction.responseThumbnail = IMLEXResources.htmlIcon;
        } else if ([mimeType isEqual:@"application/x-plist"]) {
            transaction.responseThumbnail = IMLEXResources.plistIcon;
        } else if ([mimeType isEqual:@"application/octet-stream"] || [mimeType isEqual:@"application/binary"]) {
            transaction.responseThumbnail = IMLEXResources.binaryIcon;
        } else if ([mimeType containsString:@"javascript"]) {
            transaction.responseThumbnail = IMLEXResources.jsIcon;
        } else if ([mimeType containsString:@"xml"]) {
            transaction.responseThumbnail = IMLEXResources.xmlIcon;
        } else if ([mimeType hasPrefix:@"audio"]) {
            transaction.responseThumbnail = IMLEXResources.audioIcon;
        } else if ([mimeType hasPrefix:@"video"]) {
            transaction.responseThumbnail = IMLEXResources.videoIcon;
        } else if ([mimeType hasPrefix:@"text"]) {
            transaction.responseThumbnail = IMLEXResources.textIcon;
        }
        
        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordLoadingFailedWithRequestID:(NSString *)requestID error:(NSError *)error {
    dispatch_async(self.queue, ^{
        IMLEXNetworkTransaction *transaction = self.requestIDsToTransactions[requestID];
        if (!transaction) {
            return;
        }
        
        transaction.transactionState = IMLEXNetworkTransactionStateFailed;
        transaction.duration = -[transaction.startTime timeIntervalSinceNow];
        transaction.error = error;

        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordMechanism:(NSString *)mechanism forRequestID:(NSString *)requestID {
    dispatch_async(self.queue, ^{
        IMLEXNetworkTransaction *transaction = self.requestIDsToTransactions[requestID];
        if (!transaction) {
            return;
        }
        
        transaction.requestMechanism = mechanism;
        [self postUpdateNotificationForTransaction:transaction];
    });
}

#pragma mark Notification Posting

- (void)postNewTransactionNotificationWithTransaction:(IMLEXNetworkTransaction *)transaction {
    [self notify:kIMLEXNetworkRecorderNewTransactionNotification transaction:transaction];
}

- (void)postUpdateNotificationForTransaction:(IMLEXNetworkTransaction *)transaction {
    [self notify:kIMLEXNetworkRecorderTransactionUpdatedNotification transaction:transaction];
}

- (void)notify:(NSString *)name transaction:(IMLEXNetworkTransaction *)transaction {
    NSDictionary *userInfo = nil;
    if (transaction) {
        userInfo = @{ kIMLEXNetworkRecorderUserInfoTransactionKey : transaction };
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSNotificationCenter.defaultCenter postNotificationName:name object:self userInfo:userInfo];
    });
}

@end
