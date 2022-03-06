//
//  NSMapTable+IMLEX_Subscripting.m
//  IMLEX
//
//  Created by Tanner Bennett on 1/9/20.
//  Copyright © 2020 Flipboard. All rights reserved.
//

#import "NSMapTable+IMLEX_Subscripting.h"

@implementation NSMapTable (IMLEX_Subscripting)

- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    [self setObject:obj forKey:key];
}

@end
