//
//  IMLEXManager+Networking.m
//  IMLEX
//
//  Created by Tanner on 2/1/20.
//  Copyright © 2020 Flipboard. All rights reserved.
//

#import "IMLEXManager+Networking.h"
#import "IMLEXManager+Private.h"
#import "IMLEXNetworkObserver.h"
#import "IMLEXNetworkRecorder.h"
#import "IMLEXObjectExplorerFactory.h"

@implementation IMLEXManager (Networking)

+ (void)load {
    // Register array/dictionary viewer for JSON responses
    [self.sharedManager setCustomViewerForContentType:@"application/json"
        viewControllerFutureBlock:^UIViewController *(NSData *data) {
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (jsonObject) {
                return [IMLEXObjectExplorerFactory explorerViewControllerForObject:jsonObject];
            }
        
            return nil;
        }
    ];
}

- (BOOL)isNetworkDebuggingEnabled {
    return IMLEXNetworkObserver.isEnabled;
}

- (void)setNetworkDebuggingEnabled:(BOOL)networkDebuggingEnabled {
    IMLEXNetworkObserver.enabled = networkDebuggingEnabled;
}

- (NSUInteger)networkResponseCacheByteLimit {
    return IMLEXNetworkRecorder.defaultRecorder.responseCacheByteLimit;
}

- (void)setNetworkResponseCacheByteLimit:(NSUInteger)networkResponseCacheByteLimit {
    IMLEXNetworkRecorder.defaultRecorder.responseCacheByteLimit = networkResponseCacheByteLimit;
}

- (NSMutableArray<NSString *> *)networkRequestHostBlacklist {
    return IMLEXNetworkRecorder.defaultRecorder.hostBlacklist;
}

- (void)setNetworkRequestHostBlacklist:(NSMutableArray<NSString *> *)networkRequestHostBlacklist {
    IMLEXNetworkRecorder.defaultRecorder.hostBlacklist = networkRequestHostBlacklist;
}

- (void)setCustomViewerForContentType:(NSString *)contentType
            viewControllerFutureBlock:(IMLEXCustomContentViewerFuture)viewControllerFutureBlock {
    NSParameterAssert(contentType.length);
    NSParameterAssert(viewControllerFutureBlock);
    NSAssert(NSThread.isMainThread, @"This method must be called from the main thread.");

    self.customContentTypeViewers[contentType.lowercaseString] = viewControllerFutureBlock;
}

@end
