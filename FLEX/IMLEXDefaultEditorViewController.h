//
//  IMLEXDefaultEditorViewController.h
//  Flipboard
//
//  Created by Ryan Olson on 5/23/14.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXFieldEditorViewController.h"

@interface IMLEXDefaultEditorViewController : IMLEXFieldEditorViewController

- (id)initWithDefaults:(NSUserDefaults *)defaults key:(NSString *)key;

+ (BOOL)canEditDefaultWithValue:(id)currentValue;

@end
