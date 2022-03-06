//
//  IMLEXViewControllerShortcuts.m
//  IMLEX
//
//  Created by Tanner Bennett on 12/12/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXViewControllerShortcuts.h"
#import "IMLEXObjectExplorerFactory.h"
#import "IMLEXRuntimeUtility.h"
#import "IMLEXShortcut.h"
#import "IMLEXAlert.h"

@interface IMLEXViewControllerShortcuts ()
@property (nonatomic, readonly) UIViewController *viewController;
@property (nonatomic, readonly) BOOL viewControllerIsInUse;
@end

@implementation IMLEXViewControllerShortcuts

#pragma mark - Internal

- (UIViewController *)viewController {
    return self.object;
}

/// A view controller is "in use" if it's view is in a window,
/// or if it belongs to a navigation stack which is in use.
- (BOOL)viewControllerIsInUse {
    if (self.viewController.view.window) {
        return YES;
    }

    return self.viewController.navigationController != nil;
}


#pragma mark - Overrides

+ (instancetype)forObject:(UIViewController *)viewController {
    BOOL (^vcIsInuse)(UIViewController *) = ^BOOL(UIViewController *controller) {
        if (controller.view.window) {
            return YES;
        }

        return controller.navigationController != nil;
    };
    
    return [self forObject:viewController additionalRows:@[
        [IMLEXActionShortcut title:@"Push View Controller"
            subtitle:^NSString *(UIViewController *controller) {
                return vcIsInuse(controller) ? @"In use, cannot push" : nil;
            }
            selectionHandler:^void(UIViewController *host, UIViewController *controller) {
                if (!vcIsInuse(controller)) {
                    [host.navigationController pushViewController:controller animated:YES];
                } else {
                    [IMLEXAlert
                        showAlert:@"Cannot Push View Controller"
                        message:@"This view controller's view is currently in use."
                        from:host
                    ];
                }
            }
            accessoryType:^UITableViewCellAccessoryType(UIViewController *controller) {
                if (!vcIsInuse(controller)) {
                    return UITableViewCellAccessoryDisclosureIndicator;
                } else {
                    return UITableViewCellAccessoryNone;
                }
            }
        ]
    ]];
}

@end
