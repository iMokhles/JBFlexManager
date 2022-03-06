//
//  UIBarButtonItem+IMLEX.h
//  IMLEX
//
//  Created by Tanner on 2/4/20.
//  Copyright © 2020 Flipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IMLEXBarButtonItemSystem(item, tgt, sel) \
    [UIBarButtonItem systemItem:UIBarButtonSystemItem##item target:tgt action:sel]

@interface UIBarButtonItem (IMLEX)

@property (nonatomic, readonly, class) UIBarButtonItem *IMLEX_IMLEXibleSpace;
@property (nonatomic, readonly, class) UIBarButtonItem *IMLEX_fixedSpace;

+ (instancetype)itemWithCustomView:(UIView *)customView;
+ (instancetype)backItemWithTitle:(NSString *)title;

+ (instancetype)systemItem:(UIBarButtonSystemItem)item target:(id)target action:(SEL)action;

+ (instancetype)itemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (instancetype)doneStyleitemWithTitle:(NSString *)title target:(id)target action:(SEL)action;

+ (instancetype)itemWithImage:(UIImage *)image target:(id)target action:(SEL)action;

+ (instancetype)disabledSystemItem:(UIBarButtonSystemItem)item;
+ (instancetype)disabledItemWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style;
+ (instancetype)disabledItemWithImage:(UIImage *)image;

/// @return the receiver
- (UIBarButtonItem *)withTintColor:(UIColor *)tint;

- (void)_setWidth:(CGFloat)width;

@end
