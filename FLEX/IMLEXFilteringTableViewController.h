//
//  IMLEXFilteringTableViewController.h
//  IMLEX
//
//  Created by Tanner on 3/9/20.
//  Copyright © 2020 Flipboard. All rights reserved.
//

#import "IMLEXTableViewController.h"

#pragma mark - IMLEXTableViewFiltering
@protocol IMLEXTableViewFiltering <IMLEXSearchResultsUpdating>

/// An array of visible, "filtered" sections. For example,
/// if you have 3 sections in \c allSections and the user searches
/// for something that matches rows in only one section, then
/// this property would only contain that on matching section.
@property (nonatomic, copy) NSArray<IMLEXTableViewSection *> *sections;
/// An array of all possible sections. Empty sections are to be removed
/// and the resulting array stored in the \c section property. Setting
/// this property should immediately set \c sections to \c nonemptySections 
///
/// Do not manually initialize this property, it will be
/// initialized for you using the result of \c makeSections.
@property (nonatomic, copy) NSArray<IMLEXTableViewSection *> *allSections;

/// This computed property should filter \c allSections for assignment to \c sections
@property (nonatomic, readonly) NSArray<IMLEXTableViewSection *> *nonemptySections;

/// This should be able to re-initialize \c allSections
- (NSArray<IMLEXTableViewSection *> *)makeSections;

@end


#pragma mark - IMLEXFilteringTableViewController
/// A table view which implements \c UITableView* methods using arrays of
/// \c IMLEXTableViewSection objects provied by a special delegate.
@interface IMLEXFilteringTableViewController : IMLEXTableViewController <IMLEXTableViewFiltering>

/// Stores the current search query.
@property (nonatomic, copy) NSString *filterText;

/// This property is set to \c self by default.
///
/// This property is used to power almost all of the table view's data source
/// and delegate methods automatically, including row and section filtering
/// when the user searches, 3D Touch context menus, row selection, etc.
///
/// Setting this property will also set \c searchDelegate to that object.
@property (nonatomic, weak) id<IMLEXTableViewFiltering> filterDelegate;

/// Defaults to \c NO. If enabled, all filtering will be done by calling
/// \c onBackgroundQueue:thenOnMainQueue: with the UI updated on the main queue.
@property (nonatomic) BOOL filterInBackground;

/// Defaults to \c NO. If enabled, one • will be supplied as an index title for each section.
@property (nonatomic) BOOL wantsSectionIndexTitles;

/// Recalculates the non-empty sections and reloads the table view.
///
/// Subclasses may override to perform additional reloading logic,
/// such as calling \c -reloadSections if needed. Be sure to call
/// \c super after any logic that would affect the appearance of 
/// the table view, since the table view is reloaded last.
///
/// Called at the end of this class's implementation of \c updateSearchResults:
- (void)reloadData;

/// Invoke this method to call \c -reloadData on each section
/// in \c self.filterDelegate.allSections.
- (void)reloadSections;

#pragma mark IMLEXTableViewFiltering

@property (nonatomic, copy) NSArray<IMLEXTableViewSection *> *sections;
@property (nonatomic, copy) NSArray<IMLEXTableViewSection *> *allSections;

/// Subclasses can override to hide specific sections under certain conditions
/// if using \c self as the \c filterDelegate, as is the default.
///
/// For example, the object explorer hides the description section when searching.
@property (nonatomic, readonly) NSArray<IMLEXTableViewSection *> *nonemptySections;

/// If using \c self as the \c filterDelegate, as is the default,
/// subclasses should override to provide the sections for the table view.
- (NSArray<IMLEXTableViewSection *> *)makeSections;

@end
