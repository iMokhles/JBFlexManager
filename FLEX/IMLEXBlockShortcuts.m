//
// IMLEXBlockShortcuts.m
//  IMLEX
//
//  Created by Tanner on 1/30/20.
//  Copyright © 2020 Flipboard. All rights reserved.
//

#import "IMLEXBlockShortcuts.h"
#import "IMLEXShortcut.h"
#import "IMLEXBlockDescription.h"
#import "IMLEXObjectExplorerFactory.h"

#pragma mark - 
@implementation IMLEXBlockShortcuts

#pragma mark Overrides

+ (instancetype)forObject:(id)block {
    NSParameterAssert([block isKindOfClass:NSClassFromString(@"NSBlock")]);
    
    IMLEXBlockDescription *blockInfo = [IMLEXBlockDescription describing:block];
    NSMethodSignature *signature = blockInfo.signature;
    NSArray *blockShortcutRows = @[blockInfo.summary];
    
    if (signature) {
        blockShortcutRows = @[
            blockInfo.summary,
            blockInfo.sourceDeclaration,
            signature.debugDescription,
            [IMLEXActionShortcut title:@"View Method Signature"
                subtitle:^NSString *(id block) {
                    return signature.description ?: @"unsupported signature";
                }
                viewer:^UIViewController *(id block) {
                    return [IMLEXObjectExplorerFactory explorerViewControllerForObject:signature];
                }
                accessoryType:^UITableViewCellAccessoryType(id view) {
                    if (signature) {
                        return UITableViewCellAccessoryDisclosureIndicator;
                    }
                    return UITableViewCellAccessoryNone;
                }
            ]
        ];
    }
    
    return [self forObject:block additionalRows:blockShortcutRows];
}

- (NSString *)title {
    return @"Metadata";
}

- (NSInteger)numberOfLines {
    return 0;
}

@end
