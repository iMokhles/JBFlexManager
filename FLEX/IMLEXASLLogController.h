//
//  IMLEXASLLogController.h
//  IMLEX
//
//  Created by Tanner on 3/14/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXLogController.h"

@interface IMLEXASLLogController : NSObject <IMLEXLogController>

/// Guaranteed to call back on the main thread.
+ (instancetype)withUpdateHandler:(void(^)(NSArray<IMLEXSystemLogMessage *> *newMessages))newMessagesHandler;

- (BOOL)startMonitoring;

@end
