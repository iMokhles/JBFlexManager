//
//  IMLEXArgumentInputNotSupportedView.m
//  Flipboard
//
//  Created by Ryan Olson on 6/18/14.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXArgumentInputNotSupportedView.h"
#import "IMLEXColor.h"

@implementation IMLEXArgumentInputNotSupportedView

- (instancetype)initWithArgumentTypeEncoding:(const char *)typeEncoding {
    self = [super initWithArgumentTypeEncoding:typeEncoding];
    if (self) {
        self.inputTextView.userInteractionEnabled = NO;
        self.inputTextView.backgroundColor = [IMLEXColor secondaryGroupedBackgroundColorWithAlpha:0.5];
        self.inputPlaceholderText = @"nil  (type not supported)";
        self.targetSize = IMLEXArgumentInputViewSizeSmall;
    }
    return self;
}

@end
