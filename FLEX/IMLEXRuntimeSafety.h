//
//  IMLEXRuntimeSafety.h
//  IMLEX
//
//  Created by Tanner on 3/25/17.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#pragma mark - Classes

extern NSUInteger const kIMLEXKnownUnsafeClassCount;
extern const Class * IMLEXKnownUnsafeClassList(void);
extern NSSet * IMLEXKnownUnsafeClassNames(void);
extern CFSetRef IMLEXKnownUnsafeClasses;

static Class cNSObject = nil, cNSProxy = nil;

__attribute__((constructor))
static void IMLEXInitKnownRootClasses() {
    cNSObject = [NSObject class];
    cNSProxy = [NSProxy class];
}

static inline BOOL IMLEXClassIsSafe(Class cls) {
    // Is it nil or known to be unsafe?
    if (!cls || CFSetContainsValue(IMLEXKnownUnsafeClasses, (__bridge void *)cls)) {
        return NO;
    }
    
    // Is it a known root class?
    if (!class_getSuperclass(cls)) {
        return cls == cNSObject || cls == cNSProxy;
    }
    
    // Probably safe
    return YES;
}

static inline BOOL IMLEXClassNameIsSafe(NSString *cls) {
    if (!cls) return NO;
    
    NSSet *ignored = IMLEXKnownUnsafeClassNames();
    return ![ignored containsObject:cls];
}

#pragma mark - Ivars

extern CFSetRef IMLEXKnownUnsafeIvars;

static inline BOOL IMLEXIvarIsSafe(Ivar ivar) {
    if (!ivar) return NO;

    return !CFSetContainsValue(IMLEXKnownUnsafeIvars, ivar);
}
