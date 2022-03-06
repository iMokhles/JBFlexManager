//
//  IMLEXScopeCarousel.h
//  IMLEX
//
//  Created by Tanner Bennett on 7/17/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

/// Only use on iOS 10 and up. Requires iOS 10 APIs for calculating row sizes.
@interface IMLEXScopeCarousel : UIControl

@property (nonatomic, copy) NSArray<NSString *> *items;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) void(^selectedIndexChangedAction)(NSInteger idx);

- (void)registerBlockForDynamicTypeChanges:(void(^)(IMLEXScopeCarousel *))handler;

@end
