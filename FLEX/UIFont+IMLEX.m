//
//  UIFont+IMLEX.m
//  IMLEX
//
//  Created by Tanner Bennett on 12/20/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "UIFont+IMLEX.h"

#define kIMLEXDefaultCellFontSize 12.0

@implementation UIFont (IMLEX)

+ (UIFont *)IMLEX_defaultTableCellFont {
    static UIFont *defaultTableCellFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultTableCellFont = [UIFont systemFontOfSize:kIMLEXDefaultCellFontSize];
    });

    return defaultTableCellFont;
}

+ (UIFont *)IMLEX_codeFont {
    // Actually only available in iOS 13, the SDK headers are wrong
    if (@available(iOS 13, *)) {
        return [self monospacedSystemFontOfSize:kIMLEXDefaultCellFontSize weight:UIFontWeightRegular];
    } else {
        return [self fontWithName:@"Menlo-Regular" size:kIMLEXDefaultCellFontSize];
    }
}

+ (UIFont *)IMLEX_smallCodeFont {
        // Actually only available in iOS 13, the SDK headers are wrong
    if (@available(iOS 13, *)) {
        return [self monospacedSystemFontOfSize:self.smallSystemFontSize weight:UIFontWeightRegular];
    } else {
        return [self fontWithName:@"Menlo-Regular" size:self.smallSystemFontSize];
    }
}

@end
