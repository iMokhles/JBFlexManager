//
//  IMLEXRuntimeKeyPath.m
//  IMLEX
//
//  Created by Tanner on 3/22/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "IMLEXRuntimeKeyPath.h"
#include <dlfcn.h>

@interface IMLEXRuntimeKeyPath () {
    NSString *IMLEX_description;
}
@end

@implementation IMLEXRuntimeKeyPath

+ (instancetype)empty {
    static IMLEXRuntimeKeyPath *empty = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        IMLEXSearchToken *any = IMLEXSearchToken.any;

        empty = [self new];
        empty->_bundleKey = any;
        empty->IMLEX_description = @"";
    });

    return empty;
}

+ (instancetype)bundle:(IMLEXSearchToken *)bundle
                 class:(IMLEXSearchToken *)cls
                method:(IMLEXSearchToken *)method
            isInstance:(NSNumber *)instance
                string:(NSString *)keyPathString {
    IMLEXRuntimeKeyPath *keyPath  = [self new];
    keyPath->_bundleKey = bundle;
    keyPath->_classKey  = cls;
    keyPath->_methodKey = method;

    keyPath->_instanceMethods = instance;

    // Remove irrelevant trailing '*' for equality purposes
    if ([keyPathString hasSuffix:@"*"]) {
        keyPathString = [keyPathString substringToIndex:keyPathString.length];
    }
    keyPath->IMLEX_description = keyPathString;
    
    if (bundle.isAny && cls.isAny && method.isAny) {
        [self initializeWebKitLegacy];
    }

    return keyPath;
}

+ (void)initializeWebKitLegacy {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void *handle = dlopen(
            "/System/Library/PrivateFrameworks/WebKitLegacy.framework/WebKitLegacy",
            RTLD_LAZY
        );
        void (*WebKitInitialize)() = dlsym(handle, "WebKitInitialize");
        if (WebKitInitialize) {
            NSAssert(NSThread.isMainThread,
                @"WebKitInitialize can only be called on the main thread"
            );
            WebKitInitialize();
        }
    });
}

- (NSString *)description {
    return IMLEX_description;
}

- (NSUInteger)hash {
    return IMLEX_description.hash;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[IMLEXRuntimeKeyPath class]]) {
        IMLEXRuntimeKeyPath *kp = object;
        return [IMLEX_description isEqualToString:kp->IMLEX_description];
    }

    return NO;
}

@end
