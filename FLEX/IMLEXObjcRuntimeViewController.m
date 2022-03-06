//
//  IMLEXObjcRuntimeViewController.m
//  IMLEX
//
//  Created by Tanner on 3/23/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "IMLEXObjcRuntimeViewController.h"
#import "IMLEXKeyPathSearchController.h"
#import "IMLEXRuntimeBrowserToolbar.h"
#import "UIGestureRecognizer+Blocks.h"
#import "IMLEXTableView.h"
#import "IMLEXObjectExplorerFactory.h"
#import "IMLEXAlert.h"

@interface IMLEXObjcRuntimeViewController () <IMLEXKeyPathSearchControllerDelegate>

@property (nonatomic, readonly ) IMLEXKeyPathSearchController *keyPathController;
@property (nonatomic, readonly ) UIView *promptView;

@end

@implementation IMLEXObjcRuntimeViewController

#pragma mark - Setup, view events

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Search bar stuff, must be first because this creates self.searchController
    self.showsSearchBar = YES;
    self.showSearchBarInitially = YES;
    // Using pinSearchBar on this screen causes a weird visual
    // thing on the next view controller that gets pushed.
    //
    // self.pinSearchBar = YES;
    self.searchController.searchBar.placeholder = @"UIKit*.UIView.-setFrame:";

    // Search controller stuff
    // key path controller automatically assigns itself as the delegate of the search bar
    // To avoid a retain cycle below, use local variables
    UISearchBar *searchBar = self.searchController.searchBar;
    IMLEXKeyPathSearchController *keyPathController = [IMLEXKeyPathSearchController delegate:self];
    _keyPathController = keyPathController;
    _keyPathController.toolbar = [IMLEXRuntimeBrowserToolbar toolbarWithHandler:^(NSString *text, BOOL suggestion) {
        if (suggestion) {
            [keyPathController didSelectKeyPathOption:text];
        } else {
            [keyPathController didPressButton:text insertInto:searchBar];
        }
    } suggestions:keyPathController.suggestions];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // This doesn't work unless it's wrapped in this dispatch_async call
        [self.searchController.searchBar becomeFirstResponder];
    });
}


#pragma mark Delegate stuff

- (void)didSelectImagePath:(NSString *)path shortName:(NSString *)shortName {
    [IMLEXAlert makeAlert:^(IMLEXAlert *make) {
        make.title(shortName);
        make.message(@"No NSBundle associated with this path:\n\n");
        make.message(path);

        make.button(@"Copy Path").handler(^(NSArray<NSString *> *strings) {
            UIPasteboard.generalPasteboard.string = path;
        });
        make.button(@"Dismiss").cancelStyle();
    } showFrom:self];
}

- (void)didSelectBundle:(NSBundle *)bundle {
    NSParameterAssert(bundle);
    IMLEXObjectExplorerViewController *explorer = [IMLEXObjectExplorerFactory explorerViewControllerForObject:bundle];
    [self.navigationController pushViewController:explorer animated:YES];
}

- (void)didSelectClass:(Class)cls {
    NSParameterAssert(cls);
    IMLEXObjectExplorerViewController *explorer = [IMLEXObjectExplorerFactory explorerViewControllerForObject:cls];
    [self.navigationController pushViewController:explorer animated:YES];
}


#pragma mark - IMLEXGlobalsEntry

+ (NSString *)globalsEntryTitle:(IMLEXGlobalsRow)row {
    return @"📚  Runtime Browser";
}

+ (UIViewController *)globalsEntryViewController:(IMLEXGlobalsRow)row {
    UIViewController *controller = [self new];
    controller.title = [self globalsEntryTitle:row];
    return controller;
}

@end
