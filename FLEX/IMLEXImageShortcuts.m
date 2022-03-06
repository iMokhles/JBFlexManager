//
//  IMLEXImageShortcuts.m
//  IMLEX
//
//  Created by Tanner Bennett on 8/29/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXImageShortcuts.h"
#import "IMLEXImagePreviewViewController.h"
#import "IMLEXAlert.h"

@interface IMLEXImageShortcuts ()
@property (nonatomic, readonly) UIImage *image;
@end

@implementation IMLEXImageShortcuts

#pragma mark - Internal

- (UIImage *)image {
    return self.object;
}


#pragma mark - Overrides

+ (instancetype)forObject:(UIImage *)image {
    // These additional rows will appear at the beginning of the shortcuts section.
    // The methods below are written in such a way that they will not interfere
    // with properties/etc being registered alongside these
    return [self forObject:image additionalRows:@[@"View Image", @"Save Image"]];
}

/// View image
- (UIViewController *)viewControllerToPushForRow:(NSInteger)row {
    if (row == 0) {
        return [IMLEXImagePreviewViewController forImage:self.image];
    }

    return [super viewControllerToPushForRow:row];
}

/// Save image
- (void (^)(__kindof UIViewController *))didSelectRowAction:(NSInteger)row {
    if (row == 1) {
        return ^(UIViewController *host) {
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        };
    }

    return [super didSelectRowAction:row];
}

/// "Save Image" does not need a disclosure indicator
- (UITableViewCellAccessoryType)accessoryTypeForRow:(NSInteger)row {
    switch (row) {
        case 0:  return UITableViewCellAccessoryDisclosureIndicator;
        case 1:  return UITableViewCellAccessoryNone;
        default: return [super accessoryTypeForRow:row];
    }
}

@end
