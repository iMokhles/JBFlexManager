//
//  IMLEXRuntimeBrowserToolbar.h
//  IMLEX
//
//  Created by Tanner on 6/11/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "IMLEXKeyboardToolbar.h"
#import "IMLEXRuntimeKeyPath.h"

@interface IMLEXRuntimeBrowserToolbar : IMLEXKeyboardToolbar

+ (instancetype)toolbarWithHandler:(IMLEXKBToolbarAction)tapHandler suggestions:(NSArray<NSString *> *)suggestions;

- (void)setKeyPath:(IMLEXRuntimeKeyPath *)keyPath suggestions:(NSArray<NSString *> *)suggestions;

@end
