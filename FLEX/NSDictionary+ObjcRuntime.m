//
//  NSDictionary+ObjcRuntime.m
//  IMLEX
//
//  Derived from MirrorKit.
//  Created by Tanner on 7/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSDictionary+ObjcRuntime.h"
#import "IMLEXRuntimeUtility.h"

@implementation NSDictionary (ObjcRuntime)

/// See this link on how to construct a proper attributes string:
/// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
- (NSString *)propertyAttributesString {
    if (!self[kIMLEXPropertyAttributeKeyTypeEncoding]) return nil;
    
    NSMutableString *attributes = [NSMutableString new];
    [attributes appendFormat:@"T%@,", self[kIMLEXPropertyAttributeKeyTypeEncoding]];
    
    for (NSString *attribute in self.allKeys) {
        IMLEXPropertyAttribute c = (IMLEXPropertyAttribute)[attribute characterAtIndex:0];
        switch (c) {
            case IMLEXPropertyAttributeTypeEncoding:
                break;
            case IMLEXPropertyAttributeBackingIvarName:
                [attributes appendFormat:@"%@%@,",
                    kIMLEXPropertyAttributeKeyBackingIvarName,
                    self[kIMLEXPropertyAttributeKeyBackingIvarName]
                ];
                break;
            case IMLEXPropertyAttributeCopy:
                if ([self[kIMLEXPropertyAttributeKeyCopy] boolValue])
                [attributes appendFormat:@"%@,", kIMLEXPropertyAttributeKeyCopy];
                break;
            case IMLEXPropertyAttributeCustomGetter:
                [attributes appendFormat:@"%@%@,",
                    kIMLEXPropertyAttributeKeyCustomGetter,
                    self[kIMLEXPropertyAttributeKeyCustomGetter]
                ];
                break;
            case IMLEXPropertyAttributeCustomSetter:
                [attributes appendFormat:@"%@%@,",
                    kIMLEXPropertyAttributeKeyCustomSetter,
                    self[kIMLEXPropertyAttributeKeyCustomSetter]
                ];
                break;
            case IMLEXPropertyAttributeDynamic:
                if ([self[kIMLEXPropertyAttributeKeyDynamic] boolValue])
                [attributes appendFormat:@"%@,", kIMLEXPropertyAttributeKeyDynamic];
                break;
            case IMLEXPropertyAttributeGarbageCollectible:
                [attributes appendFormat:@"%@,", kIMLEXPropertyAttributeKeyGarbageCollectable];
                break;
            case IMLEXPropertyAttributeNonAtomic:
                if ([self[kIMLEXPropertyAttributeKeyNonAtomic] boolValue])
                [attributes appendFormat:@"%@,", kIMLEXPropertyAttributeKeyNonAtomic];
                break;
            case IMLEXPropertyAttributeOldTypeEncoding:
                [attributes appendFormat:@"%@%@,",
                    kIMLEXPropertyAttributeKeyOldStyleTypeEncoding,
                    self[kIMLEXPropertyAttributeKeyOldStyleTypeEncoding]
                ];
                break;
            case IMLEXPropertyAttributeReadOnly:
                if ([self[kIMLEXPropertyAttributeKeyReadOnly] boolValue])
                [attributes appendFormat:@"%@,", kIMLEXPropertyAttributeKeyReadOnly];
                break;
            case IMLEXPropertyAttributeRetain:
                if ([self[kIMLEXPropertyAttributeKeyRetain] boolValue])
                [attributes appendFormat:@"%@,", kIMLEXPropertyAttributeKeyRetain];
                break;
            case IMLEXPropertyAttributeWeak:
                if ([self[kIMLEXPropertyAttributeKeyWeak] boolValue])
                [attributes appendFormat:@"%@,", kIMLEXPropertyAttributeKeyWeak];
                break;
            default:
                return nil;
                break;
        }
    }
    
    [attributes deleteCharactersInRange:NSMakeRange(attributes.length-1, 1)];
    return attributes.copy;
}

+ (instancetype)attributesDictionaryForProperty:(objc_property_t)property {
    NSMutableDictionary *attrs = [NSMutableDictionary new];

    for (NSString *key in IMLEXRuntimeUtility.allPropertyAttributeKeys) {
        char *value = property_copyAttributeValue(property, key.UTF8String);
        if (value) {
            attrs[key] = [[NSString alloc]
                initWithBytesNoCopy:value
                length:strlen(value)
                encoding:NSUTF8StringEncoding
                freeWhenDone:YES
            ];
        }
    }

    return attrs.copy;
}

@end
