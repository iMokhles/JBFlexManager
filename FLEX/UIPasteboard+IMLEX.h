//
//  UIPasteboard+IMLEX.h
//  IMLEX
//
//  Created by Tanner Bennett on 12/9/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPasteboard (IMLEX)

/// For copying an object which could be a string, data, or number
- (void)IMLEX_copy:(id)unknownType;

@end
