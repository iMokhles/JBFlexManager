//
//  UIMenu+IMLEX.h
//  IMLEX
//
//  Created by Tanner on 1/28/20.
//  Copyright © 2020 Flipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIMenu (IMLEX)

+ (instancetype)inlineMenuWithTitle:(NSString *)title
                              image:(UIImage *)image
                           children:(NSArray<UIMenuElement *> *)children;

- (instancetype)collapsed;

@end
