//
//  IMLEXKeyboardToolbar.h
//  IMLEX
//
//  Created by Tanner on 6/11/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "IMLEXKBToolbarButton.h"

@interface IMLEXKeyboardToolbar : UIView

+ (instancetype)toolbarWithButtons:(NSArray *)buttons;

@property (nonatomic) NSArray<IMLEXKBToolbarButton*> *buttons;
@property (nonatomic) UIKeyboardAppearance appearance;

@end
