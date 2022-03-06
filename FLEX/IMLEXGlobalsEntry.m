//
//  IMLEXGlobalsEntry.m
//  IMLEX
//
//  Created by Javier Soto on 7/26/14.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXGlobalsEntry.h"

@implementation IMLEXGlobalsEntry

+ (instancetype)entryWithEntry:(Class<IMLEXGlobalsEntry>)cls row:(IMLEXGlobalsRow)row {
    BOOL providesVCs = [cls respondsToSelector:@selector(globalsEntryViewController:)];
    BOOL providesActions = [cls respondsToSelector:@selector(globalsEntryRowAction:)];
    NSParameterAssert(cls);
    NSParameterAssert(providesVCs || providesActions);

    IMLEXGlobalsEntry *entry = [self new];
    entry->_entryNameFuture = ^{ return [cls globalsEntryTitle:row]; };

    if (providesVCs) {
        id action = providesActions ? [cls globalsEntryRowAction:row] : nil;
        if (action) {
            entry->_rowAction = action;
        } else {
            entry->_viewControllerFuture = ^{ return [cls globalsEntryViewController:row]; };
        }
    } else {
        entry->_rowAction = [cls globalsEntryRowAction:row];
    }

    return entry;
}

+ (instancetype)entryWithNameFuture:(IMLEXGlobalsEntryNameFuture)nameFuture
               viewControllerFuture:(IMLEXGlobalsEntryViewControllerFuture)viewControllerFuture {
    NSParameterAssert(nameFuture);
    NSParameterAssert(viewControllerFuture);

    IMLEXGlobalsEntry *entry = [self new];
    entry->_entryNameFuture = [nameFuture copy];
    entry->_viewControllerFuture = [viewControllerFuture copy];

    return entry;
}

+ (instancetype)entryWithNameFuture:(IMLEXGlobalsEntryNameFuture)nameFuture
                             action:(IMLEXGlobalsEntryRowAction)rowSelectedAction {
    NSParameterAssert(nameFuture);
    NSParameterAssert(rowSelectedAction);

    IMLEXGlobalsEntry *entry = [self new];
    entry->_entryNameFuture = [nameFuture copy];
    entry->_rowAction = [rowSelectedAction copy];

    return entry;
}

@end

@interface IMLEXGlobalsEntry (Debugging)
@property (nonatomic, readonly) NSString *name;
@end

@implementation IMLEXGlobalsEntry (Debugging)

- (NSString *)name {
    return self.entryNameFuture();
}

@end

#pragma mark - IMLEX_concreteGlobalsEntry

@implementation NSObject (IMLEXGlobalsEntry)

+ (IMLEXGlobalsEntry *)IMLEX_concreteGlobalsEntry:(IMLEXGlobalsRow)row {
    if ([self conformsToProtocol:@protocol(IMLEXGlobalsEntry)]) {
        return [IMLEXGlobalsEntry entryWithEntry:self row:row];
    }

    return nil;
}

@end
