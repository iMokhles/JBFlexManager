//
//  IMLEXRuntimeConstants.h
//  IMLEX
//
//  Created by Tanner on 3/11/20.
//  Copyright © 2020 Flipboard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define IMLEXEncodeClass(class) ("@\"" #class "\"")
#define IMLEXEncodeObject(obj) (obj ? [NSString stringWithFormat:@"@\"%@\"", [obj class]].UTF8String : @encode(id))

// Arguments 0 and 1 are self and _cmd always
extern const unsigned int kIMLEXNumberOfImplicitArgs;

// See https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
extern NSString *const kIMLEXPropertyAttributeKeyTypeEncoding;
extern NSString *const kIMLEXPropertyAttributeKeyBackingIvarName;
extern NSString *const kIMLEXPropertyAttributeKeyReadOnly;
extern NSString *const kIMLEXPropertyAttributeKeyCopy;
extern NSString *const kIMLEXPropertyAttributeKeyRetain;
extern NSString *const kIMLEXPropertyAttributeKeyNonAtomic;
extern NSString *const kIMLEXPropertyAttributeKeyCustomGetter;
extern NSString *const kIMLEXPropertyAttributeKeyCustomSetter;
extern NSString *const kIMLEXPropertyAttributeKeyDynamic;
extern NSString *const kIMLEXPropertyAttributeKeyWeak;
extern NSString *const kIMLEXPropertyAttributeKeyGarbageCollectable;
extern NSString *const kIMLEXPropertyAttributeKeyOldStyleTypeEncoding;

typedef NS_ENUM(NSUInteger, IMLEXPropertyAttribute) {
    IMLEXPropertyAttributeTypeEncoding       = 'T',
    IMLEXPropertyAttributeBackingIvarName    = 'V',
    IMLEXPropertyAttributeCopy               = 'C',
    IMLEXPropertyAttributeCustomGetter       = 'G',
    IMLEXPropertyAttributeCustomSetter       = 'S',
    IMLEXPropertyAttributeDynamic            = 'D',
    IMLEXPropertyAttributeGarbageCollectible = 'P',
    IMLEXPropertyAttributeNonAtomic          = 'N',
    IMLEXPropertyAttributeOldTypeEncoding    = 't',
    IMLEXPropertyAttributeReadOnly           = 'R',
    IMLEXPropertyAttributeRetain             = '&',
    IMLEXPropertyAttributeWeak               = 'W'
};

typedef NS_ENUM(char, IMLEXTypeEncoding) {
    IMLEXTypeEncodingNull             = '\0',
    IMLEXTypeEncodingUnknown          = '?',
    IMLEXTypeEncodingChar             = 'c',
    IMLEXTypeEncodingInt              = 'i',
    IMLEXTypeEncodingShort            = 's',
    IMLEXTypeEncodingLong             = 'l',
    IMLEXTypeEncodingLongLong         = 'q',
    IMLEXTypeEncodingUnsignedChar     = 'C',
    IMLEXTypeEncodingUnsignedInt      = 'I',
    IMLEXTypeEncodingUnsignedShort    = 'S',
    IMLEXTypeEncodingUnsignedLong     = 'L',
    IMLEXTypeEncodingUnsignedLongLong = 'Q',
    IMLEXTypeEncodingFloat            = 'f',
    IMLEXTypeEncodingDouble           = 'd',
    IMLEXTypeEncodingLongDouble       = 'D',
    IMLEXTypeEncodingCBool            = 'B',
    IMLEXTypeEncodingVoid             = 'v',
    IMLEXTypeEncodingCString          = '*',
    IMLEXTypeEncodingObjcObject       = '@',
    IMLEXTypeEncodingObjcClass        = '#',
    IMLEXTypeEncodingSelector         = ':',
    IMLEXTypeEncodingArrayBegin       = '[',
    IMLEXTypeEncodingArrayEnd         = ']',
    IMLEXTypeEncodingStructBegin      = '{',
    IMLEXTypeEncodingStructEnd        = '}',
    IMLEXTypeEncodingUnionBegin       = '(',
    IMLEXTypeEncodingUnionEnd         = ')',
    IMLEXTypeEncodingQuote            = '\"',
    IMLEXTypeEncodingBitField         = 'b',
    IMLEXTypeEncodingPointer          = '^',
    IMLEXTypeEncodingConst            = 'r'
};
