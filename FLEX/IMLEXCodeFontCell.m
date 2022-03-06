//
//  IMLEXCodeFontCell.m
//  IMLEX
//
//  Created by Tanner on 12/27/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXCodeFontCell.h"
#import "UIFont+IMLEX.h"

@implementation IMLEXCodeFontCell

- (void)postInit {
    [super postInit];
    
    self.titleLabel.font = UIFont.IMLEX_codeFont;
    self.subtitleLabel.font = UIFont.IMLEX_codeFont;

    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.9;
    self.subtitleLabel.adjustsFontSizeToFitWidth = YES;
    self.subtitleLabel.minimumScaleFactor = 0.75;
    
    // Disable mutli-line pre iOS 11
    if (@available(iOS 11, *)) {
        self.subtitleLabel.numberOfLines = 5;
    } else {
        self.titleLabel.numberOfLines = 1;
        self.subtitleLabel.numberOfLines = 1;
    }
}

@end
