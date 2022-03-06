//
//  IMLEXIvar.m
//  IMLEX
//
//  Derived from MirrorKit.
//  Created by Tanner on 6/30/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "IMLEXIvar.h"
#import "IMLEXRuntimeUtility.h"
#import "IMLEXRuntimeSafety.h"
#import "IMLEXTypeEncodingParser.h"

@interface IMLEXIvar () {
    NSString *_IMLEX_description;
}
@end

@implementation IMLEXIvar

#pragma mark Initializers

- (id)init {
    [NSException
        raise:NSInternalInconsistencyException
        format:@"Class instance should not be created with -init"
    ];
    return nil;
}

+ (instancetype)ivar:(Ivar)ivar {
    return [[self alloc] initWithIvar:ivar];
}

+ (instancetype)named:(NSString *)name onClass:(Class)cls {
    Ivar ivar = class_getInstanceVariable(cls, name.UTF8String);
    return [self ivar:ivar];
}

- (id)initWithIvar:(Ivar)ivar {
    NSParameterAssert(ivar);
    
    self = [super init];
    if (self) {
        _objc_ivar = ivar;
        [self examine];
    }
    
    return self;
}

#pragma mark Other

- (NSString *)description {
    if (!_IMLEX_description) {
        NSString *readableType = [IMLEXRuntimeUtility readableTypeForEncoding:self.typeEncoding];
        _IMLEX_description = [IMLEXRuntimeUtility appendName:self.name toType:readableType];
    }

    return _IMLEX_description;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@ name=%@, encoding=%@, offset=%ld>",
            NSStringFromClass(self.class), self.name, self.typeEncoding, (long)self.offset];
}

- (void)examine {
    _name         = @(ivar_getName(self.objc_ivar) ?: "(nil)");
    _offset       = ivar_getOffset(self.objc_ivar);
    _typeEncoding = @(ivar_getTypeEncoding(self.objc_ivar) ?: "");
    
    NSString *typeForDetails = _typeEncoding;
    NSString *sizeForDetails = nil;
    if (_typeEncoding.length) {
        _type = (IMLEXTypeEncoding)[_typeEncoding characterAtIndex:0];
        IMLEXGetSizeAndAlignment(_typeEncoding.UTF8String, &_size, nil);
        sizeForDetails = [@(_size).stringValue stringByAppendingString:@" bytes"];
    } else {
        _type = IMLEXTypeEncodingNull;
        typeForDetails = @"no type info";
        sizeForDetails = @"unknown size";
    }

    _details = [NSString stringWithFormat:
        @"%@, offset %@  —  %@",
        sizeForDetails, @(_offset), typeForDetails
    ];
}

- (id)getValue:(id)target {
    id value = nil;
    if (!IMLEXIvarIsSafe(_objc_ivar) || _type == IMLEXTypeEncodingNull) {
        return nil;
    }

#ifdef __arm64__
    // See http://www.sealiesoftware.com/blog/archive/2013/09/24/objc_explain_Non-pointer_isa.html
    if (self.type == IMLEXTypeEncodingObjcClass && [self.name isEqualToString:@"isa"]) {
        value = object_getClass(target);
    } else
#endif
    if (self.type == IMLEXTypeEncodingObjcObject || self.type == IMLEXTypeEncodingObjcClass) {
        value = object_getIvar(target, self.objc_ivar);
    } else {
        void *pointer = (__bridge void *)target + self.offset;
        value = [IMLEXRuntimeUtility
            valueForPrimitivePointer:pointer
            objCType:self.typeEncoding.UTF8String
        ];
    }

    return value;
}

- (void)setValue:(id)value onObject:(id)target {
    const char *typeEncodingCString = self.typeEncoding.UTF8String;
    if (self.type == IMLEXTypeEncodingObjcObject) {
        object_setIvar(target, self.objc_ivar, value);
    } else if ([value isKindOfClass:[NSValue class]]) {
        // Primitive - unbox the NSValue.
        NSValue *valueValue = (NSValue *)value;

        // Make sure that the box contained the correct type.
        NSAssert(
            strcmp(valueValue.objCType, typeEncodingCString) == 0,
            @"Type encoding mismatch (value: %s; ivar: %s) in setting ivar named: %@ on object: %@",
            valueValue.objCType, typeEncodingCString, self.name, target
        );

        NSUInteger bufferSize = 0;
        if (IMLEXGetSizeAndAlignment(typeEncodingCString, &bufferSize, NULL)) {
            void *buffer = calloc(bufferSize, 1);
            [valueValue getValue:buffer];
            void *pointer = (__bridge void *)target + self.offset;
            memcpy(pointer, buffer, bufferSize);
            free(buffer);
        }
    }
}

- (id)getPotentiallyUnboxedValue:(id)target {
    return [IMLEXRuntimeUtility
        potentiallyUnwrapBoxedPointer:[self getValue:target]
        type:self.typeEncoding.UTF8String
    ];
}

@end
