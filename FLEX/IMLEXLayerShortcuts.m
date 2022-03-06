//
//  IMLEXLayerShortcuts.m
//  IMLEX
//
//  Created by Tanner Bennett on 12/12/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXLayerShortcuts.h"
#import "IMLEXShortcut.h"
#import "IMLEXImagePreviewViewController.h"

@implementation IMLEXLayerShortcuts

+ (instancetype)forObject:(CALayer *)layer {
    return [self forObject:layer additionalRows:@[
        [IMLEXActionShortcut title:@"Preview Image" subtitle:nil
            viewer:^UIViewController *(id layer) {
                return [IMLEXImagePreviewViewController previewForLayer:layer];
            }
            accessoryType:^UITableViewCellAccessoryType(id layer) {
                return UITableViewCellAccessoryDisclosureIndicator;
            }
        ]
    ]];
}

@end
