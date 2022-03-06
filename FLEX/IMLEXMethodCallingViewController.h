//
//  IMLEXMethodCallingViewController.h
//  Flipboard
//
//  Created by Ryan Olson on 5/23/14.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXVariableEditorViewController.h"
#import "IMLEXMethod.h"

@interface IMLEXMethodCallingViewController : IMLEXVariableEditorViewController

+ (instancetype)target:(id)target method:(IMLEXMethod *)method;

@end
