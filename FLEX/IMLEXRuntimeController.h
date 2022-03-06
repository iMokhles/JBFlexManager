//
//  IMLEXRuntimeController.h
//  IMLEX
//
//  Created by Tanner on 3/23/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "IMLEXRuntimeKeyPath.h"

/// Wraps IMLEXRuntimeClient and provides caching mechanisms
@interface IMLEXRuntimeController : NSObject

/// @return An array of strings if the key path only evaluates
///         to a class or bundle; otherwise, a list of lists of IMLEXMethods.
+ (NSArray *)dataForKeyPath:(IMLEXRuntimeKeyPath *)keyPath;

/// Useful when you need to specify which classes to search in.
/// \c dataForKeyPath: will only search classes matching the class key.
/// We use this elsewhere when we need to search a class hierarchy.
+ (NSArray<NSArray<IMLEXMethod *> *> *)methodsForToken:(IMLEXSearchToken *)token
                                             instance:(NSNumber *)onlyInstanceMethods
                                            inClasses:(NSArray<NSString*> *)classes;

/// Useful when you need the classes that are associated with the
/// double list of methods returned from \c dataForKeyPath
+ (NSMutableArray<NSString *> *)classesForKeyPath:(IMLEXRuntimeKeyPath *)keyPath;

+ (NSString *)shortBundleNameForClass:(NSString *)name;

+ (NSString *)imagePathWithShortName:(NSString *)suffix;

+ (NSArray<NSString*> *)allBundleNames;

@end
