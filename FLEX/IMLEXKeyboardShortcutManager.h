//
//  IMLEXKeyboardShortcutManager.h
//  IMLEX
//
//  Created by Ryan Olson on 9/19/15.
//  Copyright © 2015 Flipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMLEXKeyboardShortcutManager : NSObject

@property (nonatomic, readonly, class) IMLEXKeyboardShortcutManager *sharedManager;

- (void)registerSimulatorShortcutWithKey:(NSString *)key
                               modifiers:(UIKeyModifierFlags)modifiers
                                  action:(dispatch_block_t)action
                             description:(NSString *)description;

@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, readonly) NSString *keyboardShortcutsDescription;

@end
