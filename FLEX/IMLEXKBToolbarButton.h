//
//  IMLEXKBToolbarButton.h
//  IMLEX
//
//  Created by Tanner on 6/11/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^IMLEXKBToolbarAction)(NSString *buttonTitle, BOOL isSuggestion);


@interface IMLEXKBToolbarButton : UIButton

/// Set to `default` to use the system appearance on iOS 13+
@property (nonatomic) UIKeyboardAppearance appearance;

+ (instancetype)buttonWithTitle:(NSString *)title;
+ (instancetype)buttonWithTitle:(NSString *)title action:(IMLEXKBToolbarAction)eventHandler;
+ (instancetype)buttonWithTitle:(NSString *)title action:(IMLEXKBToolbarAction)action forControlEvents:(UIControlEvents)controlEvents;

/// Adds the event handler for the button.
///
/// @param eventHandler The event handler block.
/// @param controlEvents The type of event.
- (void)addEventHandler:(IMLEXKBToolbarAction)eventHandler forControlEvents:(UIControlEvents)controlEvents;

@end

@interface IMLEXKBToolbarSuggestedButton : IMLEXKBToolbarButton @end
