//
//  NSArray+Functional.m
//  IMLEX
//
//  Created by Tanner Bennett on 9/25/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "NSArray+Functional.h"

#define IMLEXArrayClassIsMutable(me) ([[self class] isSubclassOfClass:[NSMutableArray class]])

@implementation NSArray (Functional)

- (__kindof NSArray *)IMLEX_mapped:(id (^)(id, NSUInteger))mapFunc {
    NSMutableArray *map = [NSMutableArray new];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id ret = mapFunc(obj, idx);
        if (ret) {
            [map addObject:ret];
        }
    }];

    if (self.count < 2048 && !IMLEXArrayClassIsMutable(self)) {
        return map.copy;
    }

    return map;
}

- (__kindof NSArray *)IMLEX_flatmapped:(NSArray *(^)(id, NSUInteger))block {
    NSMutableArray *array = [NSMutableArray new];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *toAdd = block(obj, idx);
        if (toAdd) {
            [array addObjectsFromArray:toAdd];
        }
    }];

    if (array.count < 2048 && !IMLEXArrayClassIsMutable(self)) {
        return array.copy;
    }

    return array;
}

- (NSArray *)IMLEX_filtered:(BOOL (^)(id, NSUInteger))filterFunc {
    return [self IMLEX_mapped:^id(id obj, NSUInteger idx) {
        return filterFunc(obj, idx) ? obj : nil;
    }];
}

- (void)IMLEX_forEach:(void(^)(id, NSUInteger))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj, idx);
    }];
}

- (instancetype)IMLEX_subArrayUpto:(NSUInteger)maxLength {
    if (maxLength > self.count) {
        if (IMLEXArrayClassIsMutable(self)) {
            return self.mutableCopy;
        }
        
        return self;
    }
    
    return [self subarrayWithRange:NSMakeRange(0, maxLength)];
}

+ (__kindof NSArray *)IMLEX_forEachUpTo:(NSUInteger)bound map:(id(^)(NSUInteger))block {
    NSMutableArray *array = [NSMutableArray new];
    for (NSUInteger i = 0; i < bound; i++) {
        id obj = block(i);
        if (obj) {
            [array addObject:obj];
        }
    }

    // For performance reasons, don't copy large arrays
    if (bound < 2048 && !IMLEXArrayClassIsMutable(self)) {
        return array.copy;
    }

    return array;
}


+ (instancetype)IMLEX_mapped:(id<NSFastEnumeration>)collection block:(id(^)(id obj, NSUInteger idx))mapFunc {
    NSMutableArray *array = [NSMutableArray new];
    NSInteger idx = 0;
    for (id obj in collection) {
        id ret = mapFunc(obj, idx++);
        if (ret) {
            [array addObject:ret];
        }
    }

    // For performance reasons, don't copy large arrays
    if (array.count < 2048) {
        return array.copy;
    }

    return array;
}

- (instancetype)sortedUsingSelector:(SEL)selector {
    if (IMLEXArrayClassIsMutable(self)) {
        NSMutableArray *me = (id)self;
        [me sortUsingSelector:selector];
        return me;
    } else {
        return [self sortedArrayUsingSelector:selector];
    }
}

@end
