//
//  IMLEXRuntimeBrowserToolbar.m
//  IMLEX
//
//  Created by Tanner on 6/11/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "IMLEXRuntimeBrowserToolbar.h"
#import "IMLEXRuntimeKeyPathTokenizer.h"

@interface IMLEXRuntimeBrowserToolbar ()
@property (nonatomic, copy) IMLEXKBToolbarAction tapHandler;
@end

@implementation IMLEXRuntimeBrowserToolbar

+ (instancetype)toolbarWithHandler:(IMLEXKBToolbarAction)tapHandler suggestions:(NSArray<NSString *> *)suggestions {
    NSArray *buttons = [self
        buttonsForKeyPath:IMLEXRuntimeKeyPath.empty suggestions:suggestions handler:tapHandler
    ];

    IMLEXRuntimeBrowserToolbar *me = [self toolbarWithButtons:buttons];
    me.tapHandler = tapHandler;
    return me;
}

+ (NSArray<IMLEXKBToolbarButton*> *)buttonsForKeyPath:(IMLEXRuntimeKeyPath *)keyPath
                                     suggestions:(NSArray<NSString *> *)suggestions
                                         handler:(IMLEXKBToolbarAction)handler {
    NSMutableArray *buttons = [NSMutableArray new];
    IMLEXSearchToken *lastKey = nil;
    BOOL lastKeyIsMethod = NO;

    if (keyPath.methodKey) {
        lastKey = keyPath.methodKey;
        lastKeyIsMethod = YES;
    } else {
        lastKey = keyPath.classKey ?: keyPath.bundleKey;
    }

    switch (lastKey.options) {
        case TBWildcardOptionsNone:
        case TBWildcardOptionsAny:
            if (lastKeyIsMethod) {
                if (!keyPath.instanceMethods) {
                    [buttons addObject:[IMLEXKBToolbarButton buttonWithTitle:@"-" action:handler]];
                    [buttons addObject:[IMLEXKBToolbarButton buttonWithTitle:@"+" action:handler]];
                }
                [buttons addObject:[IMLEXKBToolbarButton buttonWithTitle:@"*" action:handler]];
            } else {
                [buttons addObject:[IMLEXKBToolbarButton buttonWithTitle:@"*" action:handler]];
                [buttons addObject:[IMLEXKBToolbarButton buttonWithTitle:@"*." action:handler]];
            }
            break;

        default: {
            if (lastKey.options & TBWildcardOptionsPrefix) {
                if (lastKeyIsMethod) {
                    if (lastKey.string.length) {
                        [buttons addObject:[IMLEXKBToolbarButton buttonWithTitle:@"*" action:handler]];
                    }
                } else {
                    if (lastKey.string.length) {
                        [buttons addObject:[IMLEXKBToolbarButton buttonWithTitle:@"*." action:handler]];
                    }
                }
            }

            else if (lastKey.options & TBWildcardOptionsSuffix) {
                if (!lastKeyIsMethod) {
                    [buttons addObject:[IMLEXKBToolbarButton buttonWithTitle:@"*" action:handler]];
                    [buttons addObject:[IMLEXKBToolbarButton buttonWithTitle:@"*." action:handler]];
                }
            }
        }
    }
    
    for (NSString *suggestion in suggestions) {
        [buttons addObject:[IMLEXKBToolbarSuggestedButton buttonWithTitle:suggestion action:handler]];
    }

    return buttons;
}

- (void)setKeyPath:(IMLEXRuntimeKeyPath *)keyPath suggestions:(NSArray<NSString *> *)suggestions {
    self.buttons = [self.class
        buttonsForKeyPath:keyPath suggestions:suggestions handler:self.tapHandler
    ];
}

@end
