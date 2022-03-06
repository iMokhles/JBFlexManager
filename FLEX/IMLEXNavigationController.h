//
//  IMLEXNavigationController.h
//  IMLEX
//
//  Created by Tanner on 1/30/20.
//  Copyright © 2020 Flipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMLEXNavigationController : UINavigationController

+ (instancetype)withRootViewController:(UIViewController *)rootVC;

@end

NS_ASSUME_NONNULL_END
