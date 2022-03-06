//
//  IMLEXRuntimeClient.m
//  IMLEX
//
//  Created by Tanner on 3/22/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "IMLEXRuntimeClient.h"
#import "NSObject+Reflection.h"
#import "IMLEXMethod.h"
#import "NSArray+Functional.h"
#import "IMLEXRuntimeSafety.h"

#define Equals(a, b)    ([a compare:b options:NSCaseInsensitiveSearch] == NSOrderedSame)
#define Contains(a, b)  ([a rangeOfString:b options:NSCaseInsensitiveSearch].location != NSNotFound)
#define HasPrefix(a, b) ([a rangeOfString:b options:NSCaseInsensitiveSearch].location == 0)
#define HasSuffix(a, b) ([a rangeOfString:b options:NSCaseInsensitiveSearch].location == (a.length - b.length))


@interface IMLEXRuntimeClient () {
    NSMutableArray<NSString *> *_imageDisplayNames;
}

@property (nonatomic) NSMutableDictionary *bundles_pathToShort;
@property (nonatomic) NSMutableDictionary *bundles_shortToPath;
@property (nonatomic) NSCache *bundles_pathToClassNames;
@property (nonatomic) NSMutableArray<NSString *> *imagePaths;

@end

/// @return success if the map passes.
static inline NSString * TBWildcardMap_(NSString *token, NSString *candidate, NSString *success, TBWildcardOptions options) {
    switch (options) {
        case TBWildcardOptionsNone:
            // Only "if equals"
            if (Equals(candidate, token)) {
                return success;
            }
        default: {
            // Only "if contains"
            if (options & TBWildcardOptionsPrefix &&
                options & TBWildcardOptionsSuffix) {
                if (Contains(candidate, token)) {
                    return success;
                }
            }
            // Only "if candidate ends with with token"
            else if (options & TBWildcardOptionsPrefix) {
                if (HasSuffix(candidate, token)) {
                    return success;
                }
            }
            // Only "if candidate starts with with token"
            else if (options & TBWildcardOptionsSuffix) {
                // Case like "Bundle." where we want "" to match anything
                if (!token.length) {
                    return success;
                }
                if (HasPrefix(candidate, token)) {
                    return success;
                }
            }
        }
    }

    return nil;
}

/// @return candidate if the map passes.
static inline NSString * TBWildcardMap(NSString *token, NSString *candidate, TBWildcardOptions options) {
    return TBWildcardMap_(token, candidate, candidate, options);
}

@implementation IMLEXRuntimeClient

#pragma mark - Initialization

+ (instancetype)runtime {
    static IMLEXRuntimeClient *runtime;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        runtime = [self new];
        [runtime reloadLibrariesList];
    });

    return runtime;
}

- (id)init {
    self = [super init];
    if (self) {
        _imagePaths = [NSMutableArray new];
        _bundles_pathToShort = [NSMutableDictionary new];
        _bundles_shortToPath = [NSMutableDictionary new];
        _bundles_pathToClassNames = [NSCache new];
    }

    return self;
}

#pragma mark - Private

- (void)reloadLibrariesList {
    unsigned int imageCount = 0;
    const char **imageNames = objc_copyImageNames(&imageCount);

    if (imageNames) {
        NSMutableArray *imageNameStrings = [NSMutableArray IMLEX_forEachUpTo:imageCount map:^NSString *(NSUInteger i) {
            return @(imageNames[i]);
        }];

        self.imagePaths = imageNameStrings;
        free(imageNames);

        // Sort alphabetically
        [imageNameStrings sortUsingComparator:^NSComparisonResult(NSString *name1, NSString *name2) {
            NSString *shortName1 = [self shortNameForImageName:name1];
            NSString *shortName2 = [self shortNameForImageName:name2];
            return [shortName1 caseInsensitiveCompare:shortName2];
        }];

        // Cache image display names
        _imageDisplayNames = [imageNameStrings IMLEX_mapped:^id(NSString *path, NSUInteger idx) {
            return [self shortNameForImageName:path];
        }];
    }
}

- (NSString *)shortNameForImageName:(NSString *)imageName {
    // Cache
    NSString *shortName = _bundles_pathToShort[imageName];
    if (shortName) {
        return shortName;
    }

    NSArray *components = [imageName componentsSeparatedByString:@"/"];
    if (components.count >= 2) {
        NSString *parentDir = components[components.count - 2];
        if ([parentDir hasSuffix:@".framework"] || [parentDir hasSuffix:@".axbundle"]) {
            if ([imageName hasSuffix:@".dylib"]) {
                shortName = imageName.lastPathComponent;
            } else {
                shortName = parentDir;
            }
        }
    }

    if (!shortName) {
        shortName = imageName.lastPathComponent;
    }

    _bundles_pathToShort[imageName] = shortName;
    _bundles_shortToPath[shortName] = imageName;
    return shortName;
}

- (NSString *)imageNameForShortName:(NSString *)imageName {
    return _bundles_shortToPath[imageName];
}

- (NSMutableArray<NSString *> *)classNamesInImageAtPath:(NSString *)path {
    // Check cache
    NSMutableArray *classNameStrings = [_bundles_pathToClassNames objectForKey:path];
    if (classNameStrings) {
        return classNameStrings.mutableCopy;
    }

    unsigned int classCount = 0;
    const char **classNames = objc_copyClassNamesForImage(path.UTF8String, &classCount);

    if (classNames) {
        classNameStrings = [NSMutableArray IMLEX_forEachUpTo:classCount map:^id(NSUInteger i) {
            return @(classNames[i]);
        }];

        free(classNames);

        [classNameStrings sortUsingSelector:@selector(caseInsensitiveCompare:)];
        [_bundles_pathToClassNames setObject:classNameStrings forKey:path];

        return classNameStrings.mutableCopy;
    }

    return [NSMutableArray new];
}

#pragma mark - Public

- (NSMutableArray<NSString *> *)bundleNamesForToken:(IMLEXSearchToken *)token {
    if (self.imagePaths.count) {
        TBWildcardOptions options = token.options;
        NSString *query = token.string;

        // Optimization, avoid a loop
        if (options == TBWildcardOptionsAny) {
            return _imageDisplayNames;
        }

        // No dot syntax because imageDisplayNames is only mutable internally
        return [_imageDisplayNames IMLEX_mapped:^id(NSString *binary, NSUInteger idx) {
//            NSString *UIName = [self shortNameForImageName:binary];
            return TBWildcardMap(query, binary, options);
        }];
    }

    return [NSMutableArray new];
}

- (NSMutableArray<NSString *> *)bundlePathsForToken:(IMLEXSearchToken *)token {
    if (self.imagePaths.count) {
        TBWildcardOptions options = token.options;
        NSString *query = token.string;

        // Optimization, avoid a loop
        if (options == TBWildcardOptionsAny) {
            return self.imagePaths;
        }

        return [self.imagePaths IMLEX_mapped:^id(NSString *binary, NSUInteger idx) {
            NSString *UIName = [self shortNameForImageName:binary];
            // If query == UIName, -> binary
            return TBWildcardMap_(query, UIName, binary, options);
        }];
    }

    return [NSMutableArray new];
}

- (NSMutableArray<NSString *> *)classesForToken:(IMLEXSearchToken *)token inBundles:(NSMutableArray<NSString *> *)bundles {
    // Edge case where token is the class we want already; return superclasses
    if (token.isAbsolute) {
        if (IMLEXClassIsSafe(NSClassFromString(token.string))) {
            return [NSMutableArray arrayWithObject:token.string];
        }

        return [NSMutableArray new];
    }

    if (bundles.count) {
        // Get class names, remove unsafe classes
        NSMutableArray<NSString *> *names = [self _classesForToken:token inBundles:bundles];
        return [names IMLEX_mapped:^NSString *(NSString *name, NSUInteger idx) {
            Class cls = NSClassFromString(name);
            BOOL safe = IMLEXClassIsSafe(cls);
            return safe ? name : nil;
        }];
    }

    return [NSMutableArray new];
}

- (NSMutableArray<NSString *> *)_classesForToken:(IMLEXSearchToken *)token inBundles:(NSMutableArray<NSString *> *)bundles {
    TBWildcardOptions options = token.options;
    NSString *query = token.string;

    // Optimization, avoid unnecessary sorting
    if (bundles.count == 1) {
        // Optimization, avoid a loop
        if (options == TBWildcardOptionsAny) {
            return [self classNamesInImageAtPath:bundles.firstObject];
        }

        return [[self classNamesInImageAtPath:bundles.firstObject] IMLEX_mapped:^id(NSString *className, NSUInteger idx) {
            return TBWildcardMap(query, className, options);
        }];
    }
    else {
        // Optimization, avoid a loop
        if (options == TBWildcardOptionsAny) {
            return [[bundles IMLEX_flatmapped:^NSArray *(NSString *bundlePath, NSUInteger idx) {
                return [self classNamesInImageAtPath:bundlePath];
            }] sortedUsingSelector:@selector(caseInsensitiveCompare:)];
        }

        return [[bundles IMLEX_flatmapped:^NSArray *(NSString *bundlePath, NSUInteger idx) {
            return [[self classNamesInImageAtPath:bundlePath] IMLEX_mapped:^id(NSString *className, NSUInteger idx) {
                return TBWildcardMap(query, className, options);
            }];
        }] sortedUsingSelector:@selector(caseInsensitiveCompare:)];
    }
}

- (NSArray<NSMutableArray<IMLEXMethod *> *> *)methodsForToken:(IMLEXSearchToken *)token
                                                    instance:(NSNumber *)checkInstance
                                                   inClasses:(NSArray<NSString *> *)classes {
    if (classes.count) {
        TBWildcardOptions options = token.options;
        BOOL instance = checkInstance.boolValue;
        NSString *selector = token.string;

        switch (options) {
            // In practice I don't think this case is ever used with methods,
            // since they will always have a suffix wildcard at the end
            case TBWildcardOptionsNone: {
                SEL sel = (SEL)selector.UTF8String;
                return @[[classes IMLEX_mapped:^id(NSString *name, NSUInteger idx) {
                    Class cls = NSClassFromString(name);
                    // Use metaclass if not instance
                    if (!instance) {
                        cls = object_getClass(cls);
                    }
                    
                    // Method is absolute
                    return [IMLEXMethod selector:sel class:cls];
                }]];
            }
            case TBWildcardOptionsAny: {
                return [classes IMLEX_mapped:^NSArray *(NSString *name, NSUInteger idx) {
                    // Any means `instance` was not specified
                    Class cls = NSClassFromString(name);
                    return [cls IMLEX_allMethods];
                }];
            }
            default: {
                // Only "if contains"
                if (options & TBWildcardOptionsPrefix &&
                    options & TBWildcardOptionsSuffix) {
                    return [classes IMLEX_mapped:^NSArray *(NSString *name, NSUInteger idx) {
                        Class cls = NSClassFromString(name);
                        return [[cls IMLEX_allMethods] IMLEX_mapped:^id(IMLEXMethod *method, NSUInteger idx) {

                            // Method is a prefix-suffix wildcard
                            if (Contains(method.selectorString, selector)) {
                                return method;
                            }
                            return nil;
                        }];
                    }];
                }
                // Only "if method ends with with selector"
                else if (options & TBWildcardOptionsPrefix) {
                    return [classes IMLEX_mapped:^NSArray *(NSString *name, NSUInteger idx) {
                        Class cls = NSClassFromString(name);

                        return [[cls IMLEX_allMethods] IMLEX_mapped:^id(IMLEXMethod *method, NSUInteger idx) {
                            // Method is a prefix wildcard
                            if (HasSuffix(method.selectorString, selector)) {
                                return method;
                            }
                            return nil;
                        }];
                    }];
                }
                // Only "if method starts with with selector"
                else if (options & TBWildcardOptionsSuffix) {
                    assert(checkInstance);

                    return [classes IMLEX_mapped:^NSArray *(NSString *name, NSUInteger idx) {
                        Class cls = NSClassFromString(name);

                        // Case like "Bundle.class.-" where we want "-" to match anything
                        if (!selector.length) {
                            if (instance) {
                                return [cls IMLEX_allInstanceMethods];
                            } else {
                                return [cls IMLEX_allClassMethods];
                            }
                        }

                        id mapping = ^id(IMLEXMethod *method) {
                            // Method is a suffix wildcard
                            if (HasPrefix(method.selectorString, selector)) {
                                return method;
                            }
                            return nil;
                        };

                        if (instance) {
                            return [[cls IMLEX_allInstanceMethods] IMLEX_mapped:mapping];
                        } else {
                            return [[cls IMLEX_allClassMethods] IMLEX_mapped:mapping];
                        }
                    }];
                }
            }
        }
    }
    
    return [NSMutableArray new];
}

@end
