//
//  IMLEXCollectionContentSection.h
//  IMLEX
//
//  Created by Tanner Bennett on 8/28/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXTableViewSection.h"
#import "IMLEXObjectInfoSection.h"
@class IMLEXCollectionContentSection, IMLEXTableViewCell;
@protocol IMLEXCollection, IMLEXMutableCollection;

typedef id<IMLEXCollection>(^IMLEXCollectionContentFuture)(__kindof IMLEXCollectionContentSection *section);

#pragma mark Collection
/// A protocol that enables \c IMLEXCollectionContentSection to operate on any arbitrary collection.
/// \c NSArray, \c NSDictionary, \c NSSet, and \c NSOrderedSet all conform to this protocol.
@protocol IMLEXCollection <NSObject, NSFastEnumeration>

@property (nonatomic, readonly) NSUInteger count;

- (id)copy;
- (id)mutableCopy;

@optional

/// Unordered, unkeyed collections must implement this
@property (nonatomic, readonly) NSArray *allObjects;
/// Keyed collections must implement this and \c objectForKeyedSubscript:
@property (nonatomic, readonly) NSArray *allKeys;

/// Ordered, indexed collections must implement this.
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
/// Keyed, unordered collections must implement this and \c allKeys
- (id)objectForKeyedSubscript:(id)idx;

@end

@protocol IMLEXMutableCollection <IMLEXCollection>
- (void)filterUsingPredicate:(NSPredicate *)predicate;
@end

@interface NSArray (IMLEXCollection) <IMLEXCollection> @end
@interface NSSet (IMLEXCollection) <IMLEXCollection> @end
@interface NSOrderedSet (IMLEXCollection) <IMLEXCollection> @end
@interface NSDictionary (IMLEXCollection) <IMLEXCollection> @end

@interface NSMutableArray (IMLEXMutableCollection) <IMLEXMutableCollection> @end
@interface NSMutableSet (IMLEXMutableCollection) <IMLEXMutableCollection> @end
@interface NSMutableOrderedSet (IMLEXMutableCollection) <IMLEXMutableCollection> @end
@interface NSMutableDictionary (IMLEXMutableCollection) <IMLEXMutableCollection>
- (void)filterUsingPredicate:(NSPredicate *)predicate;
@end


#pragma mark - IMLEXCollectionContentSection
/// A custom section for viewing collection elements.
///
/// Tapping on a row pushes an object explorer for that element.
@interface IMLEXCollectionContentSection<__covariant ObjectType> : IMLEXTableViewSection <IMLEXObjectInfoSection> {
    @protected
    /// Unused if initialized with a future
    id<IMLEXCollection> _collection;
    /// Unused if initialized with a collection
    IMLEXCollectionContentFuture _collectionFuture;
    /// The filtered collection from \c _collection or \c _collectionFuture
    id<IMLEXCollection> _cachedCollection;
}

+ (instancetype)forCollection:(id<IMLEXCollection>)collection;
/// The future given should be safe to call more than once.
/// The result of calling this future multiple times may yield
/// different results each time if the data is changing by nature.
+ (instancetype)forReusableFuture:(IMLEXCollectionContentFuture)collectionFuture;

/// Defaults to \c NO
@property (nonatomic) BOOL hideSectionTitle;
/// Defaults to \c nil
@property (nonatomic) NSString *customTitle;
/// Defaults to \c NO
///
/// Settings this to \c NO will not display the element index for ordered collections.
/// This property only applies to \c NSArray or \c NSOrderedSet and their subclasses.
@property (nonatomic) BOOL hideOrderIndexes;

/// Set this property to provide a custom filter matcher.
///
/// By default, the collection will filter on the title and subtitle of the row.
/// So if you don't ever call \c configureCell: for example, you will need to set
/// this property so that your filter logic will match how you're setting up the cell. 
@property (nonatomic) BOOL (^customFilter)(NSString *filterText, ObjectType element);

/// Get the object in the collection associated with the given row.
/// For dictionaries, this returns the value, not the key.
- (ObjectType)objectForRow:(NSInteger)row;

@end
