//
//  IMLEXClassShortcuts.m
//  IMLEX
//
//  Created by Tanner Bennett on 11/22/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXClassShortcuts.h"
#import "IMLEXShortcut.h"
#import "IMLEXObjectExplorerFactory.h"
#import "IMLEXObjectListViewController.h"
#import "NSObject+Reflection.h"

@interface IMLEXClassShortcuts ()
@property (nonatomic, readonly) Class cls;
@end

@implementation IMLEXClassShortcuts

+ (instancetype)forObject:(Class)cls {
    // These additional rows will appear at the beginning of the shortcuts section.
    // The methods below are written in such a way that they will not interfere
    // with properties/etc being registered alongside these
    return [self forObject:cls additionalRows:@[
        [IMLEXActionShortcut title:@"Find Live Instances" subtitle:nil
            viewer:^UIViewController *(id obj) {
                return [IMLEXObjectListViewController
                    instancesOfClassWithName:NSStringFromClass(obj)
                ];
            }
            accessoryType:^UITableViewCellAccessoryType(id obj) {
                return UITableViewCellAccessoryDisclosureIndicator;
            }
        ],
        [IMLEXActionShortcut title:@"List Subclasses" subtitle:nil
            viewer:^UIViewController *(id obj) {
                NSString *name = NSStringFromClass(obj);
                return [IMLEXObjectListViewController subclassesOfClassWithName:name];
            }
            accessoryType:^UITableViewCellAccessoryType(id view) {
                return UITableViewCellAccessoryDisclosureIndicator;
            }
        ],
        [IMLEXActionShortcut title:@"Explore Bundle for Class"
            subtitle:^NSString *(id obj) {
                return [self shortNameForBundlePath:[NSBundle bundleForClass:obj].executablePath];
            }
            viewer:^UIViewController *(id obj) {
                NSBundle *bundle = [NSBundle bundleForClass:obj];
                return [IMLEXObjectExplorerFactory explorerViewControllerForObject:bundle];
            }
            accessoryType:^UITableViewCellAccessoryType(id view) {
                return UITableViewCellAccessoryDisclosureIndicator;
            }
        ],
    ]];
}

+ (NSString *)shortNameForBundlePath:(NSString *)imageName {
    NSArray<NSString *> *components = [imageName componentsSeparatedByString:@"/"];
    if (components.count >= 2) {
        return [NSString stringWithFormat:@"%@/%@",
            components[components.count - 2],
            components[components.count - 1]
        ];
    }

    return imageName.lastPathComponent;
}

@end
