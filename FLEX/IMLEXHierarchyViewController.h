//
//  IMLEXHierarchyViewController.h
//  IMLEX
//
//  Created by Tanner Bennett on 1/9/20.
//  Copyright © 2020 Flipboard. All rights reserved.
//

#import "IMLEXNavigationController.h"

@protocol IMLEXHierarchyDelegate <NSObject>
- (void)viewHierarchyDidDismiss:(UIView *)selectedView;
@end

/// A navigation controller which manages two child view controllers:
/// a 3D Reveal-like hierarchy explorer, and a 2D tree-list hierarchy explorer.
@interface IMLEXHierarchyViewController : IMLEXNavigationController

+ (instancetype)delegate:(id<IMLEXHierarchyDelegate>)delegate;
+ (instancetype)delegate:(id<IMLEXHierarchyDelegate>)delegate
              viewsAtTap:(NSArray<UIView *> *)viewsAtTap
            selectedView:(UIView *)selectedView;

- (void)toggleHierarchyMode;

@end
