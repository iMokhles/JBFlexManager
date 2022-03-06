//
//  IMLEXAlert.h
//  IMLEX
//
//  Created by Tanner Bennett on 8/20/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMLEXAlert, IMLEXAlertAction;

typedef void (^IMLEXAlertReveal)(void);
typedef void (^IMLEXAlertBuilder)(IMLEXAlert *make);
typedef IMLEXAlert *(^IMLEXAlertStringProperty)(NSString *);
typedef IMLEXAlert *(^IMLEXAlertStringArg)(NSString *);
typedef IMLEXAlert *(^IMLEXAlertTextField)(void(^configurationHandler)(UITextField *textField));
typedef IMLEXAlertAction *(^IMLEXAlertAddAction)(NSString *title);
typedef IMLEXAlertAction *(^IMLEXAlertActionStringProperty)(NSString *);
typedef IMLEXAlertAction *(^IMLEXAlertActionProperty)(void);
typedef IMLEXAlertAction *(^IMLEXAlertActionBOOLProperty)(BOOL);
typedef IMLEXAlertAction *(^IMLEXAlertActionHandler)(void(^handler)(NSArray<NSString *> *strings));

@interface IMLEXAlert : NSObject

/// Shows a simple alert with one button which says "Dismiss"
+ (void)showAlert:(NSString *)title message:(NSString *)message from:(UIViewController *)viewController;

/// Construct and display an alert
+ (void)makeAlert:(IMLEXAlertBuilder)block showFrom:(UIViewController *)viewController;
/// Construct and display an action sheet-style alert
+ (void)makeSheet:(IMLEXAlertBuilder)block showFrom:(UIViewController *)viewController;

/// Construct an alert
+ (UIAlertController *)makeAlert:(IMLEXAlertBuilder)block;
/// Construct an action sheet-style alert
+ (UIAlertController *)makeSheet:(IMLEXAlertBuilder)block;

/// Set the alert's title.
///
/// Call in succession to append strings to the title.
@property (nonatomic, readonly) IMLEXAlertStringProperty title;
/// Set the alert's message.
///
/// Call in succession to append strings to the message.
@property (nonatomic, readonly) IMLEXAlertStringProperty message;
/// Add a button with a given title with the default style and no action.
@property (nonatomic, readonly) IMLEXAlertAddAction button;
/// Add a text field with the given (optional) placeholder text.
@property (nonatomic, readonly) IMLEXAlertStringArg textField;
/// Add and configure the given text field.
///
/// Use this if you need to more than set the placeholder, such as
/// supply a delegate, make it secure entry, or change other attributes.
@property (nonatomic, readonly) IMLEXAlertTextField configuredTextField;

@end

@interface IMLEXAlertAction : NSObject

/// Set the action's title.
///
/// Call in succession to append strings to the title.
@property (nonatomic, readonly) IMLEXAlertActionStringProperty title;
/// Make the action destructive. It appears with red text.
@property (nonatomic, readonly) IMLEXAlertActionProperty destructiveStyle;
/// Make the action cancel-style. It appears with a bolder font.
@property (nonatomic, readonly) IMLEXAlertActionProperty cancelStyle;
/// Enable or disable the action. Enabled by default.
@property (nonatomic, readonly) IMLEXAlertActionBOOLProperty enabled;
/// Give the button an action. The action takes an array of text field strings.
@property (nonatomic, readonly) IMLEXAlertActionHandler handler;
/// Access the underlying UIAlertAction, should you need to change it while
/// the encompassing alert is being displayed. For example, you may want to
/// enable or disable a button based on the input of some text fields in the alert.
/// Do not call this more than once per instance.
@property (nonatomic, readonly) UIAlertAction *action;

@end
