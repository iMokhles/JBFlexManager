//
//  IMLEXCollectionContentSection.m
//  IMLEX
//
//  Created by Tanner Bennett on 8/28/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXCollectionContentSection.h"
#import "IMLEXUtility.h"
#import "IMLEXRuntimeUtility.h"
#import "IMLEXSubtitleTableViewCell.h"
#import "IMLEXTableView.h"
#import "IMLEXObjectExplorerFactory.h"

typedef NS_ENUM(NSUInteger, IMLEXCollectionType) {
    IMLEXUnsupportedCollection,
    IMLEXOrderedCollection,
    IMLEXUnorderedCollection,
    IMLEXKeyedCollection
};

@interface IMLEXCollectionContentSection ()
@property (nonatomic, copy) id<IMLEXCollection> cachedCollection;
@property (nonatomic, readonly) id<IMLEXCollection> collection;
@property (nonatomic, readonly) IMLEXCollectionContentFuture collectionFuture;
@property (nonatomic, readonly) IMLEXCollectionType collectionType;
@end

@implementation IMLEXCollectionContentSection
@synthesize filterText = _filterText;

#pragma mark Initialization

+ (instancetype)forObject:(id)object {
    return [self forCollection:object];
}

+ (id)forCollection:(id<IMLEXCollection>)collection {
    IMLEXCollectionContentSection *section = [self new];
    section->_collectionType = [self typeForCollection:collection];
    section->_collection = collection;
    section.cachedCollection = collection;
    return section;
}

+ (id)forReusableFuture:(IMLEXCollectionContentFuture)collectionFuture {
    IMLEXCollectionContentSection *section = [self new];
    section->_collectionFuture = collectionFuture;
    section.cachedCollection = collectionFuture(section);
    section->_collectionType = [self typeForCollection:section.cachedCollection];
    return section;
}


#pragma mark - Misc

+ (IMLEXCollectionType)typeForCollection:(id<IMLEXCollection>)collection {
    // Order matters here, as NSDictionary is keyed but it responds to allObjects
    if ([collection respondsToSelector:@selector(objectAtIndex:)]) {
        return IMLEXOrderedCollection;
    }
    if ([collection respondsToSelector:@selector(objectForKey:)]) {
        return IMLEXKeyedCollection;
    }
    if ([collection respondsToSelector:@selector(allObjects)]) {
        return IMLEXUnorderedCollection;
    }

    [NSException raise:NSInvalidArgumentException
                format:@"Given collection does not properly conform to IMLEXCollection"];
    return IMLEXUnsupportedCollection;
}

/// Row titles
/// - Ordered: the index
/// - Unordered: the object
/// - Keyed: the key
- (NSString *)titleForRow:(NSInteger)row {
    switch (self.collectionType) {
        case IMLEXOrderedCollection:
            if (!self.hideOrderIndexes) {
                return @(row).stringValue;
            }
            // Fall-through
        case IMLEXUnorderedCollection:
            return [self describe:[self objectForRow:row]];
        case IMLEXKeyedCollection:
            return [self describe:self.cachedCollection.allKeys[row]];

        case IMLEXUnsupportedCollection:
            return nil;
    }
}

/// Row subtitles
/// - Ordered: the object
/// - Unordered: nothing
/// - Keyed: the value
- (NSString *)subtitleForRow:(NSInteger)row {
    switch (self.collectionType) {
        case IMLEXOrderedCollection:
            if (!self.hideOrderIndexes) {
                nil;
            }
            // Fall-through
        case IMLEXKeyedCollection:
            return [self describe:[self objectForRow:row]];
        case IMLEXUnorderedCollection:
            return nil;

        case IMLEXUnsupportedCollection:
            return nil;
    }
}

- (NSString *)describe:(id)object {
    return [IMLEXRuntimeUtility summaryForObject:object];
}

- (id)objectForRow:(NSInteger)row {
    switch (self.collectionType) {
        case IMLEXOrderedCollection:
            return self.cachedCollection[row];
        case IMLEXUnorderedCollection:
            return self.cachedCollection.allObjects[row];
        case IMLEXKeyedCollection:
            return self.cachedCollection[self.cachedCollection.allKeys[row]];

        case IMLEXUnsupportedCollection:
            return nil;
    }
}


#pragma mark - Overrides

- (NSString *)title {
    if (!self.hideSectionTitle) {
        if (self.customTitle) {
            return self.customTitle;
        }
        
        return IMLEXPluralString(self.cachedCollection.count, @"Entries", @"Entry");
    }
    
    return nil;
}

- (NSInteger)numberOfRows {
    return self.cachedCollection.count;
}

- (void)setFilterText:(NSString *)filterText {
    super.filterText = filterText;
    
    if (filterText.length) {
        BOOL (^matcher)(id, id) = self.customFilter ?: ^BOOL(NSString *query, id obj) {
            return [[self describe:obj] localizedCaseInsensitiveContainsString:query];
        };
        
        NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bindings) {
            return matcher(filterText, obj);
        }];
        
        id<IMLEXMutableCollection> tmp = self.collection.mutableCopy;
        [tmp filterUsingPredicate:filter];
        self.cachedCollection = tmp;
    } else {
        self.cachedCollection = self.collection ?: self.collectionFuture(self);
    }
}

- (void)reloadData {
    if (self.collectionFuture) {
        self.cachedCollection = self.collectionFuture(self);
    } else {
        self.cachedCollection = self.collection.copy;
    }
}

- (BOOL)canSelectRow:(NSInteger)row {
    return YES;
}

- (UIViewController *)viewControllerToPushForRow:(NSInteger)row {
    return [IMLEXObjectExplorerFactory explorerViewControllerForObject:[self objectForRow:row]];
}

- (NSString *)reuseIdentifierForRow:(NSInteger)row {
    return kIMLEXDetailCell;
}

- (void)configureCell:(__kindof IMLEXTableViewCell *)cell forRow:(NSInteger)row {
    cell.titleLabel.text = [self titleForRow:row];
    cell.subtitleLabel.text = [self subtitleForRow:row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

@end


#pragma mark - NSMutableDictionary

@implementation NSMutableDictionary (IMLEXMutableCollection)

- (void)filterUsingPredicate:(NSPredicate *)predicate {
    id test = ^BOOL(id key, NSUInteger idx, BOOL *stop) {
        if ([predicate evaluateWithObject:key]) {
            return NO;
        }
        
        return ![predicate evaluateWithObject:self[key]];
    };
    
    NSArray *keys = self.allKeys;
    NSIndexSet *remove = [keys indexesOfObjectsPassingTest:test];
    
    [self removeObjectsForKeys:[keys objectsAtIndexes:remove]];
}

@end
