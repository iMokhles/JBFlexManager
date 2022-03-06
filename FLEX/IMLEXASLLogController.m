//
//  IMLEXASLLogController.m
//  IMLEX
//
//  Created by Tanner on 3/14/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXASLLogController.h"
#import <asl.h>

// Querying the ASL is much slower in the simulator. We need a longer polling interval to keep things responsive.
#if TARGET_IPHONE_SIMULATOR
    #define updateInterval 5.0
#else
    #define updateInterval 0.5
#endif

@interface IMLEXASLLogController ()

@property (nonatomic, readonly) void (^updateHandler)(NSArray<IMLEXSystemLogMessage *> *);

@property (nonatomic) NSTimer *logUpdateTimer;
@property (nonatomic, readonly) NSMutableIndexSet *logMessageIdentifiers;

// ASL stuff

@property (nonatomic) NSUInteger heapSize;
@property (nonatomic) dispatch_queue_t logQueue;
@property (nonatomic) dispatch_io_t io;
@property (nonatomic) NSString *remaining;
@property (nonatomic) int stderror;
@property (nonatomic) NSString *lastTimestamp;

@end

@implementation IMLEXASLLogController

+ (instancetype)withUpdateHandler:(void(^)(NSArray<IMLEXSystemLogMessage *> *newMessages))newMessagesHandler {
    return [[self alloc] initWithUpdateHandler:newMessagesHandler];
}

- (id)initWithUpdateHandler:(void(^)(NSArray<IMLEXSystemLogMessage *> *newMessages))newMessagesHandler {
    NSParameterAssert(newMessagesHandler);

    self = [super init];
    if (self) {
        _updateHandler = newMessagesHandler;
        _logMessageIdentifiers = [NSMutableIndexSet new];
        self.logUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:updateInterval
                                                               target:self
                                                             selector:@selector(updateLogMessages)
                                                             userInfo:nil
                                                              repeats:YES];
    }

    return self;
}

- (void)dealloc {
    [self.logUpdateTimer invalidate];
}

- (BOOL)startMonitoring {
    [self.logUpdateTimer fire];
    return YES;
}

- (void)updateLogMessages {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray<IMLEXSystemLogMessage *> *newMessages;
        @synchronized (self) {
            newMessages = [self newLogMessagesForCurrentProcess];
            if (!newMessages.count) {
                return;
            }

            for (IMLEXSystemLogMessage *message in newMessages) {
                [self.logMessageIdentifiers addIndex:(NSUInteger)message.messageID];
            }

            self.lastTimestamp = @(asl_get(newMessages.lastObject.aslMessage, ASL_KEY_TIME) ?: "null");
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.updateHandler(newMessages);
        });
    });
}

#pragma mark - Log Message Fetching

- (NSArray<IMLEXSystemLogMessage *> *)newLogMessagesForCurrentProcess {
    if (!self.logMessageIdentifiers.count) {
        return [self allLogMessagesForCurrentProcess];
    }

    aslresponse response = [self ASLMessageListForCurrentProcess];
    aslmsg aslMessage = NULL;

    NSMutableArray<IMLEXSystemLogMessage *> *newMessages = [NSMutableArray new];

    while ((aslMessage = asl_next(response))) {
        NSUInteger messageID = (NSUInteger)atoll(asl_get(aslMessage, ASL_KEY_MSG_ID));
        if (![self.logMessageIdentifiers containsIndex:messageID]) {
            [newMessages addObject:[IMLEXSystemLogMessage logMessageFromASLMessage:aslMessage]];
        }
    }

    asl_release(response);
    return newMessages;
}

- (aslresponse)ASLMessageListForCurrentProcess {
    static NSString *pidString = nil;
    if (!pidString) {
        pidString = @([NSProcessInfo.processInfo processIdentifier]).stringValue;
    }

    // Create system log query object.
    asl_object_t query = asl_new(ASL_TYPE_QUERY);

    // Filter for messages from the current process.
    // Note that this appears to happen by default on device, but is required in the simulator.
    asl_set_query(query, ASL_KEY_PID, pidString.UTF8String, ASL_QUERY_OP_EQUAL);
    // Filter for messages after the last retrieved message.
    if (self.lastTimestamp) {
        asl_set_query(query, ASL_KEY_TIME, self.lastTimestamp.UTF8String, ASL_QUERY_OP_GREATER);
    }

    return asl_search(NULL, query);
}

- (NSArray<IMLEXSystemLogMessage *> *)allLogMessagesForCurrentProcess {
    aslresponse response = [self ASLMessageListForCurrentProcess];
    aslmsg aslMessage = NULL;

    NSMutableArray<IMLEXSystemLogMessage *> *logMessages = [NSMutableArray new];
    while ((aslMessage = asl_next(response))) {
        [logMessages addObject:[IMLEXSystemLogMessage logMessageFromASLMessage:aslMessage]];
    }
    asl_release(response);

    return logMessages;
}

@end
