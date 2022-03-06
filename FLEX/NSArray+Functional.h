//
//  NSArray+Functional.h
//  IMLEX
//
//  Created by Tanner Bennett on 9/25/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<T> (Functional)

/// Actually more like flatmap, but it seems like the objc way to allow returning nil to omit objects.
/// So, return nil from the block to omit objects, and return an object to include it in the new array.
/// Unlike flatmap, however, this will not flatten arrays of arrays into a single array.
- (__kindof NSArray *)IMLEX_mapped:(id(^)(T obj, NSUInteger idx))mapFunc;
/// Like IMLEX_mapped, but expects arrays to be returned, and flattens them into one array.
- (__kindof NSArray *)IMLEX_flatmapped:(NSArray *(^)(id, NSUInteger idx))block;
- (instancetype)IMLEX_filtered:(BOOL(^)(T obj, NSUInteger idx))filterFunc;
- (void)IMLEX_forEach:(void(^)(T obj, NSUInteger idx))block;

/// Unlike \c subArrayWithRange: this will not throw an exception if \c maxLength
/// is greater than the size of the array. If the array has one element and
/// \c maxLength is greater than 1, you get an array with 1 element back.
- (instancetype)IMLEX_subArrayUpto:(NSUInteger)maxLength;

+ (instancetype)IMLEX_forEachUpTo:(NSUInteger)bound map:(T(^)(NSUInteger i))block;
+ (instancetype)IMLEX_mapped:(id<NSFastEnumeration>)collection block:(id(^)(T obj, NSUInteger idx))mapFunc;

- (instancetype)sortedUsingSelector:(SEL)selector;

@end
