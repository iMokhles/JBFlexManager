//
//  IMLEXBundleShortcuts.m
//  IMLEX
//
//  Created by Tanner Bennett on 12/12/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXBundleShortcuts.h"
#import "IMLEXShortcut.h"
#import "IMLEXFileBrowserTableViewController.h"

#pragma mark -
@implementation IMLEXBundleShortcuts
#pragma mark Overrides

+ (instancetype)forObject:(NSBundle *)bundle {
    return [self forObject:bundle additionalRows:@[
        [IMLEXActionShortcut title:@"Browse Bundle Directory" subtitle:nil
            viewer:^UIViewController *(id view) {
                return [IMLEXFileBrowserTableViewController path:bundle.bundlePath];
            }
            accessoryType:^UITableViewCellAccessoryType(id view) {
                return UITableViewCellAccessoryDisclosureIndicator;
            }
        ]
    ]];
}

@end
