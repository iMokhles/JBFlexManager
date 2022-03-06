//
//  IMLEXImagePreviewViewController.h
//  Flipboard
//
//  Created by Ryan Olson on 6/12/14.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMLEXImagePreviewViewController : UIViewController

+ (instancetype)previewForView:(UIView *)view;
+ (instancetype)previewForLayer:(CALayer *)layer;
+ (instancetype)forImage:(UIImage *)image;

@end
