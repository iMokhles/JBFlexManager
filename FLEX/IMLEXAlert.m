//
//  IMLEXAlert.m
//  IMLEX
//
//  Created by Tanner Bennett on 8/20/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXAlert.h"

@interface IMLEXAlert ()
@property (nonatomic, readonly) UIAlertController *_controller;
@property (nonatomic, readonly) NSMutableArray<IMLEXAlertAction *> *_actions;
@end

#define IMLEXAlertActionMutationAssertion() \
NSAssert(!self._action, @"Cannot mutate action after retreiving underlying UIAlertAction");

@interface IMLEXAlertAction ()
@property (nonatomic) UIAlertController *_controller;
@property (nonatomic) NSString *_title;
@property (nonatomic) UIAlertActionStyle _style;
@property (nonatomic) BOOL _disable;
@property (nonatomic) void(^_handler)(UIAlertAction *action);
@property (nonatomic) UIAlertAction *_action;
@end

@implementation IMLEXAlert

+ (void)showAlert:(NSString *)title message:(NSString *)message from:(UIViewController *)viewController {
    [self makeAlert:^(IMLEXAlert *make) {
        make.title(title).message(message).button(@"Dismiss").cancelStyle();
    } showFrom:viewController];
}

#pragma mark Initialization

- (instancetype)initWithController:(UIAlertController *)controller {
    self = [super init];
    if (self) {
        __controller = controller;
        __actions = [NSMutableArray new];
    }

    return self;
}

+ (UIAlertController *)make:(IMLEXAlertBuilder)block withStyle:(UIAlertControllerStyle)style {
    // Create alert builder
    IMLEXAlert *alert = [[self alloc] initWithController:
        [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:style]
    ];

    // Configure alert
    block(alert);

    // Add actions
    for (IMLEXAlertAction *builder in alert._actions) {
        [alert._controller addAction:builder.action];
    }

    return alert._controller;
}

+ (void)make:(IMLEXAlertBuilder)block withStyle:(UIAlertControllerStyle)style showFrom:(UIViewController *)viewController {
    UIAlertController *alert = [self make:block withStyle:style];
    [viewController presentViewController:alert animated:YES completion:nil];
}

+ (void)makeAlert:(IMLEXAlertBuilder)block showFrom:(UIViewController *)viewController {
    [self make:block withStyle:UIAlertControllerStyleAlert showFrom:viewController];
}

+ (void)makeSheet:(IMLEXAlertBuilder)block showFrom:(UIViewController *)viewController {
    [self make:block withStyle:UIAlertControllerStyleActionSheet showFrom:viewController];
}

+ (UIAlertController *)makeAlert:(IMLEXAlertBuilder)block {
    return [self make:block withStyle:UIAlertControllerStyleAlert];
}

+ (UIAlertController *)makeSheet:(IMLEXAlertBuilder)block {
    return [self make:block withStyle:UIAlertControllerStyleActionSheet];
}

#pragma mark Configuration

- (IMLEXAlertStringProperty)title {
    return ^IMLEXAlert *(NSString *title) {
        if (self._controller.title) {
            self._controller.title = [self._controller.title stringByAppendingString:title];
        } else {
            self._controller.title = title;
        }
        return self;
    };
}

- (IMLEXAlertStringProperty)message {
    return ^IMLEXAlert *(NSString *message) {
        if (self._controller.message) {
            self._controller.message = [self._controller.message stringByAppendingString:message];
        } else {
            self._controller.message = message;
        }
        return self;
    };
}

- (IMLEXAlertAddAction)button {
    return ^IMLEXAlertAction *(NSString *title) {
        IMLEXAlertAction *action = IMLEXAlertAction.new.title(title);
        action._controller = self._controller;
        [self._actions addObject:action];
        return action;
    };
}

- (IMLEXAlertStringArg)textField {
    return ^IMLEXAlert *(NSString *placeholder) {
        [self._controller addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = placeholder;
        }];

        return self;
    };
}

- (IMLEXAlertTextField)configuredTextField {
    return ^IMLEXAlert *(void(^configurationHandler)(UITextField *)) {
        [self._controller addTextFieldWithConfigurationHandler:configurationHandler];
        return self;
    };
}

@end

@implementation IMLEXAlertAction

- (IMLEXAlertActionStringProperty)title {
    return ^IMLEXAlertAction *(NSString *title) {
        IMLEXAlertActionMutationAssertion();
        if (self._title) {
            self._title = [self._title stringByAppendingString:title];
        } else {
            self._title = title;
        }
        return self;
    };
}

- (IMLEXAlertActionProperty)destructiveStyle {
    return ^IMLEXAlertAction *() {
        IMLEXAlertActionMutationAssertion();
        self._style = UIAlertActionStyleDestructive;
        return self;
    };
}

- (IMLEXAlertActionProperty)cancelStyle {
    return ^IMLEXAlertAction *() {
        IMLEXAlertActionMutationAssertion();
        self._style = UIAlertActionStyleCancel;
        return self;
    };
}

- (IMLEXAlertActionBOOLProperty)enabled {
    return ^IMLEXAlertAction *(BOOL enabled) {
        IMLEXAlertActionMutationAssertion();
        self._disable = !enabled;
        return self;
    };
}

- (IMLEXAlertActionHandler)handler {
    return ^IMLEXAlertAction *(void(^handler)(NSArray<NSString *> *)) {
        IMLEXAlertActionMutationAssertion();

        // Get weak reference to the alert to avoid block <--> alert retain cycle
        __weak __typeof(self._controller) weakController = self._controller;
        self._handler = ^(UIAlertAction *action) {
            // Strongify that reference and pass the text field strings to the handler
            __strong __typeof(weakController) controller = weakController;
            NSArray *strings = [controller.textFields valueForKeyPath:@"text"];
            handler(strings);
        };

        return self;
    };
}

- (UIAlertAction *)action {
    if (self._action) {
        return self._action;
    }

    self._action = [UIAlertAction
        actionWithTitle:self._title
        style:self._style
        handler:self._handler
    ];
    self._action.enabled = !self._disable;

    return self._action;
}

@end
