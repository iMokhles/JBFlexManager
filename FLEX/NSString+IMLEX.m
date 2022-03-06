//
//  NSString+IMLEX.m
//  IMLEX
//
//  Created by Tanner on 3/26/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "NSString+IMLEX.h"

@interface NSMutableString (Replacement)
- (void)replaceOccurencesOfString:(NSString *)string with:(NSString *)replacement;
- (void)removeLastKeyPathComponent;
@end

@implementation NSMutableString (Replacement)

- (void)replaceOccurencesOfString:(NSString *)string with:(NSString *)replacement {
    [self replaceOccurrencesOfString:string withString:replacement options:0 range:NSMakeRange(0, self.length)];
}

- (void)removeLastKeyPathComponent {
    if (![self containsString:@"."]) {
        [self deleteCharactersInRange:NSMakeRange(0, self.length)];
        return;
    }

    BOOL putEscapesBack = NO;
    if ([self containsString:@"\\."]) {
        [self replaceOccurencesOfString:@"\\." with:@"\\~"];

        // Case like "UIKit\.framework"
        if (![self containsString:@"."]) {
            [self deleteCharactersInRange:NSMakeRange(0, self.length)];
            return;
        }

        putEscapesBack = YES;
    }

    // Case like "Bund" or "Bundle.cla"
    if (![self hasSuffix:@"."]) {
        NSUInteger len = self.pathExtension.length;
        [self deleteCharactersInRange:NSMakeRange(self.length-len, len)];
    }

    if (putEscapesBack) {
        [self replaceOccurencesOfString:@"\\~" with:@"\\."];
    }
}

@end

@implementation NSString (IMLEXTypeEncoding)

- (NSCharacterSet *)IMLEX_classNameAllowedCharactersSet {
    static NSCharacterSet *classNameAllowedCharactersSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *temp = NSMutableCharacterSet.alphanumericCharacterSet;
        [temp addCharactersInString:@"_"];
        classNameAllowedCharactersSet = temp.copy;
    });
    
    return classNameAllowedCharactersSet;
}

- (BOOL)IMLEX_typeIsConst {
    if (!self.length) return NO;
    return [self characterAtIndex:0] == IMLEXTypeEncodingConst;
}

- (IMLEXTypeEncoding)IMLEX_firstNonConstType {
    if (!self.length) return IMLEXTypeEncodingNull;
    return [self characterAtIndex:(self.IMLEX_typeIsConst ? 1 : 0)];
}

- (BOOL)IMLEX_typeIsObjectOrClass {
    IMLEXTypeEncoding type = self.IMLEX_firstNonConstType;
    return type == IMLEXTypeEncodingObjcObject || type == IMLEXTypeEncodingObjcClass;
}

- (Class)IMLEX_typeClass {
    if (!self.IMLEX_typeIsObjectOrClass) {
        return nil;
    }
    
    NSScanner *scan = [NSScanner scannerWithString:self];
    // Skip const
    [scan scanString:@"r" intoString:nil];
    // Scan leading @"
    if (![scan scanString:@"@\"" intoString:nil]) {
        return nil;
    }
    
    // Scan class name
    NSString *name = nil;
    if (![scan scanCharactersFromSet:self.IMLEX_classNameAllowedCharactersSet intoString:&name]) {
        return nil;
    }
    // Scan trailing quote
    if (![scan scanString:@"\"" intoString:nil]) {
        return nil;
    }
    
    // Return found class
    return NSClassFromString(name);
}

- (BOOL)IMLEX_typeIsNonObjcPointer {
    IMLEXTypeEncoding type = self.IMLEX_firstNonConstType;
    return type == IMLEXTypeEncodingPointer ||
           type == IMLEXTypeEncodingCString ||
           type == IMLEXTypeEncodingSelector;
}

@end

@implementation NSString (KeyPaths)

- (NSString *)stringByRemovingLastKeyPathComponent {
    if (![self containsString:@"."]) {
        return @"";
    }

    NSMutableString *mself = self.mutableCopy;
    [mself removeLastKeyPathComponent];
    return mself;
}

- (NSString *)stringByReplacingLastKeyPathComponent:(NSString *)replacement {
    // replacement should not have any escaped '.' in it,
    // so we escape all '.'
    if ([replacement containsString:@"."]) {
        replacement = [replacement stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
    }

    // Case like "Foo"
    if (![self containsString:@"."]) {
        return [replacement stringByAppendingString:@"."];
    }

    NSMutableString *mself = self.mutableCopy;
    [mself removeLastKeyPathComponent];
    [mself appendString:replacement];
    [mself appendString:@"."];
    return mself;
}

@end
