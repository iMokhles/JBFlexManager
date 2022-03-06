//
//  IMLEXArgumentInputViewFactory.m
//  IMLEXInjected
//
//  Created by Ryan Olson on 6/15/14.
//
//

#import "IMLEXArgumentInputViewFactory.h"
#import "IMLEXArgumentInputView.h"
#import "IMLEXArgumentInputObjectView.h"
#import "IMLEXArgumentInputNumberView.h"
#import "IMLEXArgumentInputSwitchView.h"
#import "IMLEXArgumentInputStructView.h"
#import "IMLEXArgumentInputNotSupportedView.h"
#import "IMLEXArgumentInputStringView.h"
#import "IMLEXArgumentInputFontView.h"
#import "IMLEXArgumentInputColorView.h"
#import "IMLEXArgumentInputDateView.h"
#import "IMLEXRuntimeUtility.h"

@implementation IMLEXArgumentInputViewFactory

+ (IMLEXArgumentInputView *)argumentInputViewForTypeEncoding:(const char *)typeEncoding {
    return [self argumentInputViewForTypeEncoding:typeEncoding currentValue:nil];
}

+ (IMLEXArgumentInputView *)argumentInputViewForTypeEncoding:(const char *)typeEncoding currentValue:(id)currentValue {
    Class subclass = [self argumentInputViewSubclassForTypeEncoding:typeEncoding currentValue:currentValue];
    if (!subclass) {
        // Fall back to a IMLEXArgumentInputNotSupportedView if we can't find a subclass that fits the type encoding.
        // The unsupported view shows "nil" and does not allow user input.
        subclass = [IMLEXArgumentInputNotSupportedView class];
    }
    // Remove the field name if there is any (e.g. \"width\"d -> d)
    const NSUInteger fieldNameOffset = [IMLEXRuntimeUtility fieldNameOffsetForTypeEncoding:typeEncoding];
    return [[subclass alloc] initWithArgumentTypeEncoding:typeEncoding + fieldNameOffset];
}

+ (Class)argumentInputViewSubclassForTypeEncoding:(const char *)typeEncoding currentValue:(id)currentValue {
    // Remove the field name if there is any (e.g. \"width\"d -> d)
    const NSUInteger fieldNameOffset = [IMLEXRuntimeUtility fieldNameOffsetForTypeEncoding:typeEncoding];
    Class argumentInputViewSubclass = nil;
    NSArray<Class> *inputViewClasses = @[[IMLEXArgumentInputColorView class],
                                         [IMLEXArgumentInputFontView class],
                                         [IMLEXArgumentInputStringView class],
                                         [IMLEXArgumentInputStructView class],
                                         [IMLEXArgumentInputSwitchView class],
                                         [IMLEXArgumentInputDateView class],
                                         [IMLEXArgumentInputNumberView class],
                                         [IMLEXArgumentInputObjectView class]];

    // Note that order is important here since multiple subclasses may support the same type.
    // An example is the number subclass and the bool subclass for the type @encode(BOOL).
    // Both work, but we'd prefer to use the bool subclass.
    for (Class inputViewClass in inputViewClasses) {
        if ([inputViewClass supportsObjCType:typeEncoding + fieldNameOffset withCurrentValue:currentValue]) {
            argumentInputViewSubclass = inputViewClass;
            break;
        }
    }

    return argumentInputViewSubclass;
}

+ (BOOL)canEditFieldWithTypeEncoding:(const char *)typeEncoding currentValue:(id)currentValue {
    return [self argumentInputViewSubclassForTypeEncoding:typeEncoding currentValue:currentValue] != nil;
}

@end
