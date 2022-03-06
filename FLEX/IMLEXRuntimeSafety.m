//
//  IMLEXRuntimeSafety.m
//  IMLEX
//
//  Created by Tanner on 3/25/17.
//

#import "IMLEXRuntimeSafety.h"

NSUInteger const kIMLEXKnownUnsafeClassCount = 19;
Class * _UnsafeClasses = NULL;
CFSetRef IMLEXKnownUnsafeClasses = nil;
CFSetRef IMLEXKnownUnsafeIvars = nil;

#define IMLEXClassPointerOrCFNull(name) \
    (NSClassFromString(name) ?: (__bridge id)kCFNull)

#define IMLEXIvarOrCFNull(cls, name) \
    (class_getInstanceVariable([cls class], name) ?: (void *)kCFNull)

__attribute__((constructor))
static void IMLEXRuntimeSafteyInit() {
    IMLEXKnownUnsafeClasses = CFSetCreate(
        kCFAllocatorDefault,
        (const void **)(uintptr_t)IMLEXKnownUnsafeClassList(),
        kIMLEXKnownUnsafeClassCount,
        nil
    );

    Ivar unsafeIvars[] = {
        IMLEXIvarOrCFNull(NSURL, "_urlString"),
        IMLEXIvarOrCFNull(NSURL, "_baseURL"),
    };
    IMLEXKnownUnsafeIvars = CFSetCreate(
        kCFAllocatorDefault,
        (const void **)unsafeIvars,
        sizeof(unsafeIvars),
        nil
    );
}

const Class * IMLEXKnownUnsafeClassList() {
    if (!_UnsafeClasses) {
        const Class ignored[] = {
            IMLEXClassPointerOrCFNull(@"__ARCLite__"),
            IMLEXClassPointerOrCFNull(@"__NSCFCalendar"),
            IMLEXClassPointerOrCFNull(@"__NSCFTimer"),
            IMLEXClassPointerOrCFNull(@"NSCFTimer"),
            IMLEXClassPointerOrCFNull(@"__NSGenericDeallocHandler"),
            IMLEXClassPointerOrCFNull(@"NSAutoreleasePool"),
            IMLEXClassPointerOrCFNull(@"NSPlaceholderNumber"),
            IMLEXClassPointerOrCFNull(@"NSPlaceholderString"),
            IMLEXClassPointerOrCFNull(@"NSPlaceholderValue"),
            IMLEXClassPointerOrCFNull(@"Object"),
            IMLEXClassPointerOrCFNull(@"VMUArchitecture"),
            IMLEXClassPointerOrCFNull(@"JSExport"),
            IMLEXClassPointerOrCFNull(@"__NSAtom"),
            IMLEXClassPointerOrCFNull(@"_NSZombie_"),
            IMLEXClassPointerOrCFNull(@"_CNZombie_"),
            IMLEXClassPointerOrCFNull(@"__NSMessage"),
            IMLEXClassPointerOrCFNull(@"__NSMessageBuilder"),
            IMLEXClassPointerOrCFNull(@"FigIrisAutoTrimmerMotionSampleExport"),
            // Temporary until we have our own type encoding parser;
            // setVectors: has an invalid type encoding and crashes NSMethodSignature
            IMLEXClassPointerOrCFNull(@"_UIPointVector"),
        };
        
        assert((sizeof(ignored) / sizeof(Class)) == kIMLEXKnownUnsafeClassCount);

        _UnsafeClasses = (Class *)malloc(sizeof(ignored));
        memcpy(_UnsafeClasses, ignored, sizeof(ignored));
    }

    return _UnsafeClasses;
}

NSSet * IMLEXKnownUnsafeClassNames() {
    static NSSet *set = nil;
    if (!set) {
        NSArray *ignored = @[
            @"__ARCLite__",
            @"__NSCFCalendar",
            @"__NSCFTimer",
            @"NSCFTimer",
            @"__NSGenericDeallocHandler",
            @"NSAutoreleasePool",
            @"NSPlaceholderNumber",
            @"NSPlaceholderString",
            @"NSPlaceholderValue",
            @"Object",
            @"VMUArchitecture",
            @"JSExport",
            @"__NSAtom",
            @"_NSZombie_",
            @"_CNZombie_",
            @"__NSMessage",
            @"__NSMessageBuilder",
            @"FigIrisAutoTrimmerMotionSampleExport",
            @"_UIPointVector",
        ];

        set = [NSSet setWithArray:ignored];
        assert(set.count == kIMLEXKnownUnsafeClassCount);
    }

    return set;
}
