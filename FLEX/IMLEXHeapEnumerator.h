//
//  IMLEXHeapEnumerator.h
//  Flipboard
//
//  Created by Ryan Olson on 5/28/14.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^IMLEX_object_enumeration_block_t)(__unsafe_unretained id object, __unsafe_unretained Class actualClass);

@interface IMLEXHeapEnumerator : NSObject

+ (void)enumerateLiveObjectsUsingBlock:(IMLEX_object_enumeration_block_t)block;

@end
