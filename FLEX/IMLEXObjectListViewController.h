//
//  IMLEXObjectListViewController.h
//  Flipboard
//
//  Created by Ryan Olson on 5/28/14.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXFilteringTableViewController.h"

@interface IMLEXObjectListViewController : IMLEXFilteringTableViewController

+ (instancetype)instancesOfClassWithName:(NSString *)className;
+ (instancetype)subclassesOfClassWithName:(NSString *)className;
+ (instancetype)objectsWithReferencesToObject:(id)object;

@end
