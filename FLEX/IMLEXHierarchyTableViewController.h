//
//  IMLEXHierarchyTableViewController.h
//  Flipboard
//
//  Created by Ryan Olson on 2014-05-01.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXTableViewController.h"

@interface IMLEXHierarchyTableViewController : IMLEXTableViewController

+ (instancetype)windows:(NSArray<UIWindow *> *)allWindows
             viewsAtTap:(NSArray<UIView *> *)viewsAtTap
           selectedView:(UIView *)selectedView;

@property (nonatomic) UIView *selectedView;
@property (nonatomic) void(^didSelectRowAction)(UIView *selectedView);

@end
