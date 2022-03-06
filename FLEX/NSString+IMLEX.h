//
//  NSString+IMLEX.h
//  IMLEX
//
//  Created by Tanner on 3/26/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "IMLEXRuntimeConstants.h"

@interface NSString (IMLEXTypeEncoding)

///@return whether this type starts with the const specifier
@property (nonatomic, readonly) BOOL IMLEX_typeIsConst;
/// @return the first char in the type encoding that is not the const specifier
@property (nonatomic, readonly) IMLEXTypeEncoding IMLEX_firstNonConstType;
/// @return whether this type is an objc object of any kind, even if it's const
@property (nonatomic, readonly) BOOL IMLEX_typeIsObjectOrClass;
/// @return the class named in this type encoding if it is of the form \c @"MYClass"
@property (nonatomic, readonly) Class IMLEX_typeClass;
/// Includes C strings and selectors as well as regular pointers
@property (nonatomic, readonly) BOOL IMLEX_typeIsNonObjcPointer;

@end

@interface NSString (KeyPaths)

- (NSString *)stringByRemovingLastKeyPathComponent;
- (NSString *)stringByReplacingLastKeyPathComponent:(NSString *)replacement;

@end
