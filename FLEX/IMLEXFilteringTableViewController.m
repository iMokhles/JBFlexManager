//
//  IMLEXFilteringTableViewController.m
//  IMLEX
//
//  Created by Tanner on 3/9/20.
//  Copyright © 2020 Flipboard. All rights reserved.
//

#import "IMLEXFilteringTableViewController.h"
#import "IMLEXTableViewSection.h"
#import "NSArray+Functional.h"

@interface IMLEXFilteringTableViewController ()

@end

@implementation IMLEXFilteringTableViewController
@synthesize allSections = _allSections;

#pragma mark - View controller lifecycle

- (void)loadView {
    [super loadView];
    
    if (!self.filterDelegate) {
        self.filterDelegate = self;
    } else {
        [self _registerCellsForReuse];
    }
}

- (void)_registerCellsForReuse {
    for (IMLEXTableViewSection *section in self.filterDelegate.allSections) {
        if (section.cellRegistrationMapping) {
            [self.tableView registerCells:section.cellRegistrationMapping];
        }
    }
}


#pragma mark - Public

- (void)setFilterDelegate:(id<IMLEXTableViewFiltering>)filterDelegate {
    _filterDelegate = filterDelegate;
    filterDelegate.allSections = [filterDelegate makeSections];
    
    if (self.isViewLoaded) {
        [self _registerCellsForReuse];
    }
}

- (void)reloadData {
    [self reloadData:self.nonemptySections];
}

- (void)reloadData:(NSArray *)nonemptySections {
    // Recalculate displayed sections
    self.filterDelegate.sections = nonemptySections;

    // Refresh table view
    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
}

- (void)reloadSections {
    for (IMLEXTableViewSection *section in self.filterDelegate.allSections) {
        [section reloadData];
    }
}


#pragma mark - Search

- (void)updateSearchResults:(NSString *)newText {
    NSArray *(^filter)() = ^NSArray *{
        self.filterText = newText;

        // Sections will adjust data based on this property
        for (IMLEXTableViewSection *section in self.filterDelegate.allSections) {
            section.filterText = newText;
        }
        
        return nil;
    };
    
    if (self.filterInBackground) {
        [self onBackgroundQueue:filter thenOnMainQueue:^(NSArray *unused) {
            if ([self.searchText isEqualToString:newText]) {
                [self reloadData];
            }
        }];
    } else {
        filter();
        [self reloadData];
    }
}


#pragma mark Filtering

- (NSArray<IMLEXTableViewSection *> *)nonemptySections {
    return [self.filterDelegate.allSections IMLEX_filtered:^BOOL(IMLEXTableViewSection *section, NSUInteger idx) {
        return section.numberOfRows > 0;
    }];
}

- (NSArray<IMLEXTableViewSection *> *)makeSections {
    return @[];
}

- (void)setAllSections:(NSArray<IMLEXTableViewSection *> *)allSections {
    _allSections = allSections.copy;
    self.sections = self.nonemptySections;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.filterDelegate.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filterDelegate.sections[section].numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.filterDelegate.sections[section].title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuse = [self.filterDelegate.sections[indexPath.section] reuseIdentifierForRow:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse forIndexPath:indexPath];
    [self.filterDelegate.sections[indexPath.section] configureCell:cell forRow:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.wantsSectionIndexTitles) {
        return [NSArray IMLEX_forEachUpTo:self.filterDelegate.sections.count map:^id(NSUInteger i) {
            return @"⦁";
        }];
    }
    
    return nil;
}


#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.filterDelegate.sections[indexPath.section] canSelectRow:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IMLEXTableViewSection *section = self.filterDelegate.sections[indexPath.section];

    void (^action)(UIViewController *) = [section didSelectRowAction:indexPath.row];
    UIViewController *details = [section viewControllerToPushForRow:indexPath.row];

    if (action) {
        action(self);
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (details) {
        [self.navigationController pushViewController:details animated:YES];
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Row is selectable but has no action or view controller"];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self.filterDelegate.sections[indexPath.section] didPressInfoButtonAction:indexPath.row](self);
}

#if IMLEX_AT_LEAST_IOS13_SDK

- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point __IOS_AVAILABLE(13.0) {
    IMLEXTableViewSection *section = self.filterDelegate.sections[indexPath.section];
    NSString *title = [section menuTitleForRow:indexPath.row];
    NSArray<UIMenuElement *> *menuItems = [section menuItemsForRow:indexPath.row sender:self];
    
    if (menuItems.count) {
        return [UIContextMenuConfiguration
            configurationWithIdentifier:nil
            previewProvider:nil
            actionProvider:^UIMenu *(NSArray<UIMenuElement *> *suggestedActions) {
                return [UIMenu menuWithTitle:title children:menuItems];
            }
        ];
    }
    
    return nil;
}

#endif

@end
