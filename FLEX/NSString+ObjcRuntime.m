//
//  NSString+ObjcRuntime.m
//  IMLEX
//
//  Derived from MirrorKit.
//  Created by Tanner on 7/1/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSString+ObjcRuntime.h"
#import "IMLEXRuntimeUtility.h"

@implementation NSString (Utilities)

- (NSString *)stringbyDeletingCharacterAtIndex:(NSUInteger)idx {
    NSMutableString *string = self.mutableCopy;
    [string replaceCharactersInRange:NSMakeRange(idx, 1) withString:@""];
    return string;
}

/// See this link on how to construct a proper attributes string:
/// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
- (NSDictionary *)propertyAttributes {
    if (!self.length) return nil;
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    
    NSArray *components = [self componentsSeparatedByString:@","];
    for (NSString *attribute in components) {
        IMLEXPropertyAttribute c = (IMLEXPropertyAttribute)[attribute characterAtIndex:0];
        switch (c) {
            case IMLEXPropertyAttributeTypeEncoding:
                // Note: the type encoding here is not always correct. Radar: FB7499230
                attributes[kIMLEXPropertyAttributeKeyTypeEncoding] = [attribute stringbyDeletingCharacterAtIndex:0];
                break;
            case IMLEXPropertyAttributeBackingIvarName:
                attributes[kIMLEXPropertyAttributeKeyBackingIvarName] = [attribute stringbyDeletingCharacterAtIndex:0];
                break;
            case IMLEXPropertyAttributeCopy:
                attributes[kIMLEXPropertyAttributeKeyCopy] = @YES;
                break;
            case IMLEXPropertyAttributeCustomGetter:
                attributes[kIMLEXPropertyAttributeKeyCustomGetter] = [attribute stringbyDeletingCharacterAtIndex:0];
                break;
            case IMLEXPropertyAttributeCustomSetter:
                attributes[kIMLEXPropertyAttributeKeyCustomSetter] = [attribute stringbyDeletingCharacterAtIndex:0];
                break;
            case IMLEXPropertyAttributeDynamic:
                attributes[kIMLEXPropertyAttributeKeyDynamic] = @YES;
                break;
            case IMLEXPropertyAttributeGarbageCollectible:
                attributes[kIMLEXPropertyAttributeKeyGarbageCollectable] = @YES;
                break;
            case IMLEXPropertyAttributeNonAtomic:
                attributes[kIMLEXPropertyAttributeKeyNonAtomic] = @YES;
                break;
            case IMLEXPropertyAttributeOldTypeEncoding:
                attributes[kIMLEXPropertyAttributeKeyOldStyleTypeEncoding] = [attribute stringbyDeletingCharacterAtIndex:0];
                break;
            case IMLEXPropertyAttributeReadOnly:
                attributes[kIMLEXPropertyAttributeKeyReadOnly] = @YES;
                break;
            case IMLEXPropertyAttributeRetain:
                attributes[kIMLEXPropertyAttributeKeyRetain] = @YES;
                break;
            case IMLEXPropertyAttributeWeak:
                attributes[kIMLEXPropertyAttributeKeyWeak] = @YES;
                break;
        }
    }

    return attributes;
}

@end
