//
//  IMLEXRuntimeController.m
//  IMLEX
//
//  Created by Tanner on 3/23/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "IMLEXRuntimeController.h"
#import "IMLEXRuntimeClient.h"
#import "IMLEXMethod.h"

@interface IMLEXRuntimeController ()
@property (nonatomic, readonly) NSCache *bundlePathsCache;
@property (nonatomic, readonly) NSCache *bundleNamesCache;
@property (nonatomic, readonly) NSCache *classNamesCache;
@property (nonatomic, readonly) NSCache *methodsCache;
@end

@implementation IMLEXRuntimeController

#pragma mark Initialization

static IMLEXRuntimeController *controller = nil;
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [self new];
    });

    return controller;
}

- (id)init {
    self = [super init];
    if (self) {
        _bundlePathsCache = [NSCache new];
        _bundleNamesCache = [NSCache new];
        _classNamesCache  = [NSCache new];
        _methodsCache     = [NSCache new];
    }

    return self;
}

#pragma mark Public

+ (NSArray *)dataForKeyPath:(IMLEXRuntimeKeyPath *)keyPath {
    if (keyPath.bundleKey) {
        if (keyPath.classKey) {
            if (keyPath.methodKey) {
                return [[self shared] methodsForKeyPath:keyPath];
            } else {
                return [[self shared] classesForKeyPath:keyPath];
            }
        } else {
            return [[self shared] bundleNamesForToken:keyPath.bundleKey];
        }
    } else {
        return @[];
    }
}

+ (NSArray<NSArray<IMLEXMethod *> *> *)methodsForToken:(IMLEXSearchToken *)token
                         instance:(NSNumber *)inst
                        inClasses:(NSArray<NSString*> *)classes {
    return [IMLEXRuntimeClient.runtime
        methodsForToken:token
        instance:inst
        inClasses:classes
    ];
}

+ (NSMutableArray<NSString *> *)classesForKeyPath:(IMLEXRuntimeKeyPath *)keyPath {
    return [[self shared] classesForKeyPath:keyPath];
}

+ (NSString *)shortBundleNameForClass:(NSString *)name {
    const char *imageName = class_getImageName(NSClassFromString(name));
    if (!imageName) {
        return @"(unspecified)";
    }
    
    return [IMLEXRuntimeClient.runtime shortNameForImageName:@(imageName)];
}

+ (NSString *)imagePathWithShortName:(NSString *)suffix {
    return [IMLEXRuntimeClient.runtime imageNameForShortName:suffix];
}

+ (NSArray *)allBundleNames {
    return IMLEXRuntimeClient.runtime.imageDisplayNames;
}

#pragma mark Private

- (NSMutableArray *)bundlePathsForToken:(IMLEXSearchToken *)token {
    // Only cache if no wildcard
    BOOL shouldCache = token == TBWildcardOptionsNone;

    if (shouldCache) {
        NSMutableArray<NSString*> *cached = [self.bundlePathsCache objectForKey:token];
        if (cached) {
            return cached;
        }

        NSMutableArray<NSString*> *bundles = [IMLEXRuntimeClient.runtime bundlePathsForToken:token];
        [self.bundlePathsCache setObject:bundles forKey:token];
        return bundles;
    }
    else {
        return [IMLEXRuntimeClient.runtime bundlePathsForToken:token];
    }
}

- (NSMutableArray<NSString *> *)bundleNamesForToken:(IMLEXSearchToken *)token {
    // Only cache if no wildcard
    BOOL shouldCache = token == TBWildcardOptionsNone;

    if (shouldCache) {
        NSMutableArray<NSString*> *cached = [self.bundleNamesCache objectForKey:token];
        if (cached) {
            return cached;
        }

        NSMutableArray<NSString*> *bundles = [IMLEXRuntimeClient.runtime bundleNamesForToken:token];
        [self.bundleNamesCache setObject:bundles forKey:token];
        return bundles;
    }
    else {
        return [IMLEXRuntimeClient.runtime bundleNamesForToken:token];
    }
}

- (NSMutableArray<NSString *> *)classesForKeyPath:(IMLEXRuntimeKeyPath *)keyPath {
    IMLEXSearchToken *classToken = keyPath.classKey;
    IMLEXSearchToken *bundleToken = keyPath.bundleKey;
    
    // Only cache if no wildcard
    BOOL shouldCache = bundleToken.options == 0 && classToken.options == 0;
    NSString *key = nil;

    if (shouldCache) {
        key = [@[bundleToken.description, classToken.description] componentsJoinedByString:@"+"];
        NSMutableArray<NSString *> *cached = [self.classNamesCache objectForKey:key];
        if (cached) {
            return cached;
        }
    }

    NSMutableArray<NSString *> *bundles = [self bundlePathsForToken:bundleToken];
    NSMutableArray<NSString *> *classes = [IMLEXRuntimeClient.runtime
        classesForToken:classToken inBundles:bundles
    ];

    if (shouldCache) {
        [self.classNamesCache setObject:classes forKey:key];
    }

    return classes;
}

- (NSArray<NSMutableArray<IMLEXMethod *> *> *)methodsForKeyPath:(IMLEXRuntimeKeyPath *)keyPath {
    // Only cache if no wildcard, but check cache anyway bc I'm lazy
    NSArray<NSMutableArray *> *cached = [self.methodsCache objectForKey:keyPath];
    if (cached) {
        return cached;
    }

    NSArray<NSString *> *classes = [self classesForKeyPath:keyPath];
    NSArray<NSMutableArray<IMLEXMethod *> *> *methodLists = [IMLEXRuntimeClient.runtime
        methodsForToken:keyPath.methodKey
        instance:keyPath.instanceMethods
        inClasses:classes
    ];

    for (NSMutableArray<IMLEXMethod *> *methods in methodLists) {
        [methods sortUsingComparator:^NSComparisonResult(IMLEXMethod *m1, IMLEXMethod *m2) {
            return [m1.description caseInsensitiveCompare:m2.description];
        }];
    }

    // Only cache if no wildcard, otherwise the cache could grow very large
    if (keyPath.bundleKey.isAbsolute &&
        keyPath.classKey.isAbsolute) {
        [self.methodsCache setObject:methodLists forKey:keyPath];
    }

    return methodLists;
}

@end
