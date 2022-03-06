//
//  IMLEXRuntimeKeyPath.h
//  IMLEX
//
//  Created by Tanner on 3/22/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "IMLEXSearchToken.h"
@class IMLEXMethod;

NS_ASSUME_NONNULL_BEGIN

/// A key path represents a query into a set of bundles or classes
/// for a set of one or more methods. It is composed of three tokens:
/// bundle, class, and method. A key path may be incomplete if it
/// is missing any of the tokens. A key path is considered "absolute"
/// if all tokens have no options and if methodKey.string begins
/// with a + or a -.
///
/// The @code TBKeyPathTokenizer @endcode class is used to create
/// a key path from a string.
@interface IMLEXRuntimeKeyPath : NSObject

+ (instancetype)empty;

/// @param method must start with either a wildcard or a + or -.
+ (instancetype)bundle:(IMLEXSearchToken *)bundle
                 class:(IMLEXSearchToken *)cls
                method:(IMLEXSearchToken *)method
            isInstance:(NSNumber *)instance
                string:(NSString *)keyPathString;

@property (nonatomic, nullable, readonly) IMLEXSearchToken *bundleKey;
@property (nonatomic, nullable, readonly) IMLEXSearchToken *classKey;
@property (nonatomic, nullable, readonly) IMLEXSearchToken *methodKey;

/// Indicates whether the method token specifies instance methods.
/// Nil if not specified.
@property (nonatomic, nullable, readonly) NSNumber *instanceMethods;

@end
NS_ASSUME_NONNULL_END
