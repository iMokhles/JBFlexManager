//
//  NSUserDefaults+IMLEX.h
//  IMLEX
//
//  Created by Tanner on 3/10/20.
//  Copyright © 2020 Flipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

// Only use these if the getters and setters aren't good enough for whatever reaso
extern NSString * const kIMLEXDefaultsToolbarTopMarginKey;
extern NSString * const kIMLEXDefaultsiOSPersistentOSLogKey;
extern NSString * const kIMLEXDefaultsHidePropertyIvarsKey;
extern NSString * const kIMLEXDefaultsHidePropertyMethodsKey;
extern NSString * const kIMLEXDefaultsHideMethodOverridesKey;
extern NSString * const kIMLEXDefaultsNetworkHostBlacklistKey;

@interface NSUserDefaults (IMLEX)

- (void)toggleBoolForKey:(NSString *)key;

@property (nonatomic) double IMLEX_toolbarTopMargin;

/// NO by default
@property (nonatomic) BOOL IMLEX_cacheOSLogMessages;

/// NO by default
@property (nonatomic) BOOL IMLEX_explorerHidesPropertyIvars;
/// NO by default
@property (nonatomic) BOOL IMLEX_explorerHidesPropertyMethods;
/// NO by default
@property (nonatomic) BOOL IMLEX_explorerShowsMethodOverrides;

// Not actually stored in defaults, but written to a file
@property (nonatomic) NSArray<NSString *> *IMLEX_networkHostBlacklist;

@end
