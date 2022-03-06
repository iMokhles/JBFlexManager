//
//  IMLEXClassShortcuts.h
//  IMLEX
//
//  Created by Tanner Bennett on 11/22/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXShortcutsSection.h"

/// Provides handy shortcuts for class objects.
/// This is the default section used for all class objects.
@interface IMLEXClassShortcuts : IMLEXShortcutsSection

+ (instancetype)forObject:(Class)cls;

@end
