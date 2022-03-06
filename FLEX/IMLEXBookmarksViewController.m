//
//  IMLEXBookmarksViewController.m
//  IMLEX
//
//  Created by Tanner on 2/6/20.
//  Copyright © 2020 Flipboard. All rights reserved.
//

#import "IMLEXBookmarksViewController.h"
#import "IMLEXExplorerViewController.h"
#import "IMLEXNavigationController.h"
#import "IMLEXObjectExplorerFactory.h"
#import "IMLEXBookmarkManager.h"
#import "UIBarButtonItem+IMLEX.h"
#import "IMLEXColor.h"
#import "IMLEXUtility.h"
#import "IMLEXRuntimeUtility.h"
#import "IMLEXTableView.h"

@interface IMLEXBookmarksViewController ()
@property (nonatomic, copy) NSArray *bookmarks;
@property (nonatomic, readonly) IMLEXExplorerViewController *corePresenter;
@end

@implementation IMLEXBookmarksViewController

#pragma mark - Initialization

- (id)init {
    return [self initWithStyle:UITableViewStylePlain];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.hidesBarsOnSwipe = NO;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupDefaultBarItems];
}


#pragma mark - Private

- (void)reloadData {
    // We assume the bookmarks aren't going to change out from under us, since
    // presenting any other tool via keyboard shortcuts should dismiss us first
    self.bookmarks = IMLEXBookmarkManager.bookmarks;
    self.title = [NSString stringWithFormat:@"Bookmarks (%@)", @(self.bookmarks.count)];
}

- (void)setupDefaultBarItems {
    self.navigationItem.rightBarButtonItem = IMLEXBarButtonItemSystem(Done, self, @selector(dismissAnimated));
    self.toolbarItems = @[
        UIBarButtonItem.IMLEX_IMLEXibleSpace,
        IMLEXBarButtonItemSystem(Edit, self, @selector(toggleEditing)),
    ];
    
    // Disable editing if no bookmarks available
    self.toolbarItems.lastObject.enabled = self.bookmarks.count > 0;
}

- (void)setupEditingBarItems {
    self.navigationItem.rightBarButtonItem = nil;
    self.toolbarItems = @[
        [UIBarButtonItem itemWithTitle:@"Close All" target:self action:@selector(closeAllButtonPressed)],
        UIBarButtonItem.IMLEX_IMLEXibleSpace,
        // We use a non-system done item because we change its title dynamically
        [UIBarButtonItem doneStyleitemWithTitle:@"Done" target:self action:@selector(toggleEditing)]
    ];
    
    self.toolbarItems.firstObject.tintColor = IMLEXColor.destructiveColor;
}

- (IMLEXExplorerViewController *)corePresenter {
    // We must be presented by a IMLEXExplorerViewController, or presented
    // by another view controller that was presented by IMLEXExplorerViewController
    IMLEXExplorerViewController *presenter = (id)self.presentingViewController;
    presenter = (id)presenter.presentingViewController ?: presenter;
    presenter = (id)presenter.presentingViewController ?: presenter;
    NSAssert(
        [presenter isKindOfClass:[IMLEXExplorerViewController class]],
        @"The bookmarks view controller expects to be presented by the explorer controller"
    );
    return presenter;
}

#pragma mark Button Actions

- (void)dismissAnimated {
    [self dismissAnimated:nil];
}

- (void)dismissAnimated:(id)selectedObject {
    if (selectedObject) {
        UIViewController *explorer = [IMLEXObjectExplorerFactory
            explorerViewControllerForObject:selectedObject
        ];
        if ([self.presentingViewController isKindOfClass:[IMLEXNavigationController class]]) {
            // I am presented on an existing navigation stack, so
            // dismiss myself and push the bookmark there
            UINavigationController *presenter = (id)self.presentingViewController;
            [presenter dismissViewControllerAnimated:YES completion:^{
                [presenter pushViewController:explorer animated:YES];
            }];
        } else {
            // Dismiss myself and present explorer
            UIViewController *presenter = self.corePresenter;
            [presenter dismissViewControllerAnimated:YES completion:^{
                [presenter presentViewController:[IMLEXNavigationController
                    withRootViewController:explorer
                ] animated:YES completion:nil];
            }];
        }
    } else {
        // Just dismiss myself
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)toggleEditing {
    NSArray<NSIndexPath *> *selected = self.tableView.indexPathsForSelectedRows;
    self.editing = !self.editing;
    
    if (self.isEditing) {
        [self setupEditingBarItems];
    } else {
        [self setupDefaultBarItems];
        
        // Get index set of bookmarks to close
        NSMutableIndexSet *indexes = [NSMutableIndexSet new];
        for (NSIndexPath *ip in selected) {
            [indexes addIndex:ip.row];
        }
        
        if (selected.count) {
            // Close bookmarks and update data source
            [IMLEXBookmarkManager.bookmarks removeObjectsAtIndexes:indexes];
            [self reloadData];
            
            // Remove deleted rows
            [self.tableView deleteRowsAtIndexPaths:selected withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (void)closeAllButtonPressed {
    [IMLEXAlert makeSheet:^(IMLEXAlert *make) {
        NSInteger count = self.bookmarks.count;
        NSString *title = IMLEXPluralFormatString(count, @"Remove %@ bookmarks", @"Remove %@ bookmark");
        make.button(title).destructiveStyle().handler(^(NSArray<NSString *> *strings) {
            [self closeAll];
            [self toggleEditing];
        });
        make.button(@"Cancel").cancelStyle();
    } showFrom:self];
}

- (void)closeAll {
    NSInteger rowCount = self.bookmarks.count;
    
    // Close bookmarks and update data source
    [IMLEXBookmarkManager.bookmarks removeAllObjects];
    [self reloadData];
    
    // Delete rows from table view
    NSArray<NSIndexPath *> *allRows = [NSArray IMLEX_forEachUpTo:rowCount map:^id(NSUInteger row) {
        return [NSIndexPath indexPathForRow:row inSection:0];
    }];
    [self.tableView deleteRowsAtIndexPaths:allRows withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bookmarks.count;
}

- (UITableViewCell *)tableView:(IMLEXTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIMLEXDetailCell forIndexPath:indexPath];
    
    id object = self.bookmarks[indexPath.row];
    cell.textLabel.text = [IMLEXRuntimeUtility safeDescriptionForObject:object];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ — %p", [object class], object];
    
    return cell;
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
        // Case: editing with multi-select
        self.toolbarItems.lastObject.title = @"Remove Selected";
        self.toolbarItems.lastObject.tintColor = IMLEXColor.destructiveColor;
    } else {
        // Case: selected a bookmark
        [self dismissAnimated:self.bookmarks[indexPath.row]];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(self.editing);
    
    if (tableView.indexPathsForSelectedRows.count == 0) {
        self.toolbarItems.lastObject.title = @"Done";
        self.toolbarItems.lastObject.tintColor = self.view.tintColor;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)table
commitEditingStyle:(UITableViewCellEditingStyle)edit
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(edit == UITableViewCellEditingStyleDelete);
    
    // Remove bookmark and update data source
    [IMLEXBookmarkManager.bookmarks removeObjectAtIndex:indexPath.row];
    [self reloadData];
    
    // Delete row from table view
    [table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
