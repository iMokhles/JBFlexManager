//
//  IMLEXRuntimeClient.h
//  IMLEX
//
//  Created by Tanner on 3/22/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "IMLEXSearchToken.h"
@class IMLEXMethod;

/// Accepts runtime queries given a token.
@interface IMLEXRuntimeClient : NSObject

@property (nonatomic, readonly, class) IMLEXRuntimeClient *runtime;

/// Called automatically when \c IMLEXRuntime is first used.
/// You may call it again when you think a library has
/// been loaded since this method was first called.
- (void)reloadLibrariesList;

/// An array of strings representing the currently loaded libraries.
@property (nonatomic, readonly) NSArray<NSString *> *imageDisplayNames;

/// "Image name" is the path of the bundle
- (NSString *)shortNameForImageName:(NSString *)imageName;
/// "Image name" is the path of the bundle
- (NSString *)imageNameForShortName:(NSString *)imageName;

/// @return Bundle names for the UI
- (NSMutableArray<NSString *> *)bundleNamesForToken:(IMLEXSearchToken *)token;
/// @return Bundle paths for more queries
- (NSMutableArray<NSString *> *)bundlePathsForToken:(IMLEXSearchToken *)token;
/// @return Class names
- (NSMutableArray<NSString *> *)classesForToken:(IMLEXSearchToken *)token
                                      inBundles:(NSMutableArray<NSString *> *)bundlePaths;
/// @return A list of lists of \c IMLEXMethods where
/// each list corresponds to one of the given classes
- (NSArray<NSMutableArray<IMLEXMethod *> *> *)methodsForToken:(IMLEXSearchToken *)token
                                                    instance:(NSNumber *)onlyInstanceMethods
                                                   inClasses:(NSArray<NSString *> *)classes;

@end
