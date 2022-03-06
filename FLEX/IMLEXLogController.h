//
//  IMLEXLogController.h
//  IMLEX
//
//  Created by Tanner on 3/17/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMLEXSystemLogMessage.h"

@protocol IMLEXLogController <NSObject>

/// Guaranteed to call back on the main thread.
+ (instancetype)withUpdateHandler:(void(^)(NSArray<IMLEXSystemLogMessage *> *newMessages))newMessagesHandler;

- (BOOL)startMonitoring;

@end
