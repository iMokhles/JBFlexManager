//
//  UIFont+IMLEX.h
//  IMLEX
//
//  Created by Tanner Bennett on 12/20/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (IMLEX)

@property (nonatomic, readonly, class) UIFont *IMLEX_defaultTableCellFont;
@property (nonatomic, readonly, class) UIFont *IMLEX_codeFont;
@property (nonatomic, readonly, class) UIFont *IMLEX_smallCodeFont;

@end
