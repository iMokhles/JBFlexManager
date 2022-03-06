//
//  NSUserDefaults+IMLEX.m
//  IMLEX
//
//  Created by Tanner on 3/10/20.
//  Copyright © 2020 Flipboard. All rights reserved.
//

#import "NSUserDefaults+IMLEX.h"

NSString * const kIMLEXDefaultsToolbarTopMarginKey = @"com.IMLEX.IMLEXToolbar.topMargin";
NSString * const kIMLEXDefaultsiOSPersistentOSLogKey = @"com.flipborad.IMLEX.enable_persistent_os_log";
NSString * const kIMLEXDefaultsHidePropertyIvarsKey = @"com.flipboard.IMLEX.hide_property_ivars";
NSString * const kIMLEXDefaultsHidePropertyMethodsKey = @"com.flipboard.IMLEX.hide_property_methods";
NSString * const kIMLEXDefaultsHideMethodOverridesKey = @"com.flipboard.IMLEX.hide_method_overrides";
NSString * const kIMLEXDefaultsNetworkHostBlacklistKey = @"com.flipboard.IMLEX.network_host_blacklist";

#define IMLEXDefaultsPathForFile(name) ({ \
    NSArray *paths = NSSearchPathForDirectoriesInDomains( \
        NSLibraryDirectory, NSUserDomainMask, NO \
    ); \
    [paths[0] stringByAppendingPathComponent:@"Preferences"]; \
})

@implementation NSUserDefaults (IMLEX)

/// @param filename the name of a plist file without any extension
- (NSString *)IMLEX_defaultsPathForFile:(NSString *)filename {
    filename = [filename stringByAppendingPathExtension:@"plist"];
    
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(
        NSLibraryDirectory, NSUserDomainMask, YES
    );
    NSString *preferences = [paths[0] stringByAppendingPathComponent:@"Preferences"];
    return [preferences stringByAppendingPathComponent:filename];
}

- (void)toggleBoolForKey:(NSString *)key {
    [self setBool:![self boolForKey:key] forKey:key];
    [NSNotificationCenter.defaultCenter postNotificationName:key object:nil];
}

- (double)IMLEX_toolbarTopMargin {
    if ([self objectForKey:kIMLEXDefaultsToolbarTopMarginKey]) {
        return [self doubleForKey:kIMLEXDefaultsToolbarTopMarginKey];
    }
    
    return 100;
}

- (void)setIMLEX_toolbarTopMargin:(double)margin {
    [self setDouble:margin forKey:kIMLEXDefaultsToolbarTopMarginKey];
}

- (BOOL)IMLEX_cacheOSLogMessages {
    return [self boolForKey:kIMLEXDefaultsiOSPersistentOSLogKey];
}

- (void)setIMLEX_cacheOSLogMessages:(BOOL)cache {
    [self setBool:cache forKey:kIMLEXDefaultsiOSPersistentOSLogKey];
    [NSNotificationCenter.defaultCenter
        postNotificationName:kIMLEXDefaultsiOSPersistentOSLogKey
        object:nil
    ];
}

- (BOOL)IMLEX_explorerHidesPropertyIvars {
    return [self boolForKey:kIMLEXDefaultsHidePropertyIvarsKey];
}

- (void)setIMLEX_explorerHidesPropertyIvars:(BOOL)hide {
    [self setBool:hide forKey:kIMLEXDefaultsHidePropertyIvarsKey];
    [NSNotificationCenter.defaultCenter
        postNotificationName:kIMLEXDefaultsHidePropertyIvarsKey
        object:nil
    ];
}

- (BOOL)IMLEX_explorerHidesPropertyMethods {
    return [self boolForKey:kIMLEXDefaultsHidePropertyMethodsKey];
}

- (void)setIMLEX_explorerHidesPropertyMethods:(BOOL)hide {
    [self setBool:hide forKey:kIMLEXDefaultsHidePropertyMethodsKey];
    [NSNotificationCenter.defaultCenter
        postNotificationName:kIMLEXDefaultsHidePropertyMethodsKey
        object:nil
    ];
}

- (BOOL)IMLEX_explorerShowsMethodOverrides {
    return [self boolForKey:kIMLEXDefaultsHideMethodOverridesKey];
}

- (void)setIMLEX_explorerShowsMethodOverrides:(BOOL)show {
    [self setBool:show forKey:kIMLEXDefaultsHideMethodOverridesKey];
    [NSNotificationCenter.defaultCenter
        postNotificationName:kIMLEXDefaultsHideMethodOverridesKey
        object:nil
    ];
}

- (NSArray<NSString *> *)IMLEX_networkHostBlacklist {
    return [NSArray arrayWithContentsOfFile:[
        self IMLEX_defaultsPathForFile:kIMLEXDefaultsNetworkHostBlacklistKey
    ]] ?: @[];
}

- (void)setIMLEX_networkHostBlacklist:(NSArray<NSString *> *)blacklist {
    NSParameterAssert(blacklist);
    [blacklist writeToFile:[
        self IMLEX_defaultsPathForFile:kIMLEXDefaultsNetworkHostBlacklistKey
    ] atomically:YES];
}

@end
