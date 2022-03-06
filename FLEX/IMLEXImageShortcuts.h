//
//  IMLEXImageShortcuts.h
//  IMLEX
//
//  Created by Tanner Bennett on 8/29/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXShortcutsSection.h"

/// Provides "view image" and "save image" shortcuts for UIImage objects
@interface IMLEXImageShortcuts : IMLEXShortcutsSection

+ (instancetype)forObject:(UIImage *)image;

@end
