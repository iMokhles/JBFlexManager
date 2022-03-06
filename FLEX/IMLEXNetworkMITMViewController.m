//
//  IMLEXNetworkMITMViewController.m
//  Flipboard
//
//  Created by Ryan Olson on 2/8/15.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXColor.h"
#import "IMLEXUtility.h"
#import "IMLEXNetworkMITMViewController.h"
#import "IMLEXNetworkTransaction.h"
#import "IMLEXNetworkRecorder.h"
#import "IMLEXNetworkObserver.h"
#import "IMLEXNetworkTransactionTableViewCell.h"
#import "IMLEXNetworkTransactionDetailTableViewController.h"
#import "IMLEXNetworkSettingsController.h"
#import "IMLEXGlobalsViewController.h"
#import "UIBarButtonItem+IMLEX.h"
#import "IMLEXResources.h"

@interface IMLEXNetworkMITMViewController ()

/// Backing model
@property (nonatomic, copy) NSArray<IMLEXNetworkTransaction *> *networkTransactions;
@property (nonatomic) long long bytesReceived;
@property (nonatomic, copy) NSArray<IMLEXNetworkTransaction *> *filteredNetworkTransactions;
@property (nonatomic) long long filteredBytesReceived;

@property (nonatomic) BOOL rowInsertInProgress;
@property (nonatomic) BOOL isPresentingSearch;
@property (nonatomic) BOOL pendingReload;

@end

@implementation IMLEXNetworkMITMViewController

#pragma mark - Lifecycle

- (id)init {
    return [self initWithStyle:UITableViewStylePlain];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.showsSearchBar = YES;
    self.showSearchBarInitially = NO;
    
    [self addToolbarItems:@[
        [UIBarButtonItem
            itemWithImage:IMLEXResources.gearIcon
            target:self
            action:@selector(settingsButtonTapped:)
        ],
        [[UIBarButtonItem
          systemItem:UIBarButtonSystemItemTrash
          target:self
          action:@selector(trashButtonTapped:)
        ] withTintColor:UIColor.redColor]
    ]];

    [self.tableView
        registerClass:[IMLEXNetworkTransactionTableViewCell class]
        forCellReuseIdentifier:kIMLEXNetworkTransactionCellIdentifier
    ];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = IMLEXNetworkTransactionTableViewCell.preferredCellHeight;

    [self registerForNotifications];
    [self updateTransactions];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Reload the table if we received updates while not on-screen
    if (self.pendingReload) {
        [self.tableView reloadData];
        self.pendingReload = NO;
    }
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)registerForNotifications {
    NSDictionary *notifications = @{
        kIMLEXNetworkRecorderNewTransactionNotification:
            NSStringFromSelector(@selector(handleNewTransactionRecordedNotification:)),
        kIMLEXNetworkRecorderTransactionUpdatedNotification:
            NSStringFromSelector(@selector(handleTransactionUpdatedNotification:)),
        kIMLEXNetworkRecorderTransactionsClearedNotification:
            NSStringFromSelector(@selector(handleTransactionsClearedNotification:)),
        kIMLEXNetworkObserverEnabledStateChangedNotification:
            NSStringFromSelector(@selector(handleNetworkObserverEnabledStateChangedNotification:)),
    };
    
    for (NSString *name in notifications.allKeys) {
        [NSNotificationCenter.defaultCenter addObserver:self
            selector:NSSelectorFromString(notifications[name]) name:name object:nil
        ];
    }
}


#pragma mark - Private

#pragma mark Button Actions

- (void)settingsButtonTapped:(id)sender {
    UIViewController *settings = [IMLEXNetworkSettingsController new];
    settings.navigationItem.rightBarButtonItem = IMLEXBarButtonItemSystem(
        Done, self, @selector(settingsViewControllerDoneTapped:)
    );
    settings.title = @"Network Debugging Settings";
    
    // This is not a IMLEXNavigationController because it is not intended as a new tab
    UIViewController *nav = [[UINavigationController alloc] initWithRootViewController:settings];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)trashButtonTapped:(id)sender {
    [IMLEXAlert makeSheet:^(IMLEXAlert *make) {
        make.title(@"Clear All Recorded Requests?");
        make.message(@"This cannot be undone.");
        
        make.button(@"Cancel").cancelStyle();
        make.button(@"Clear All").destructiveStyle().handler(^(NSArray *strings) {
            [IMLEXNetworkRecorder.defaultRecorder clearRecordedActivity];
        });
    } showFrom:self];
}

- (void)settingsViewControllerDoneTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Transactions

- (void)updateTransactions {
    self.networkTransactions = [IMLEXNetworkRecorder.defaultRecorder networkTransactions];
}

- (void)setNetworkTransactions:(NSArray<IMLEXNetworkTransaction *> *)networkTransactions {
    if (![_networkTransactions isEqual:networkTransactions]) {
        _networkTransactions = networkTransactions;
        [self updateBytesReceived];
        [self updateFilteredBytesReceived];
    }
}

- (void)updateBytesReceived {
    long long bytesReceived = 0;
    for (IMLEXNetworkTransaction *transaction in self.networkTransactions) {
        bytesReceived += transaction.receivedDataLength;
    }
    self.bytesReceived = bytesReceived;
    [self updateFirstSectionHeader];
}

- (void)setFilteredNetworkTransactions:(NSArray<IMLEXNetworkTransaction *> *)networkTransactions {
    if (![_filteredNetworkTransactions isEqual:networkTransactions]) {
        _filteredNetworkTransactions = networkTransactions;
        [self updateFilteredBytesReceived];
    }
}

- (void)updateFilteredBytesReceived {
    long long filteredBytesReceived = 0;
    for (IMLEXNetworkTransaction *transaction in self.filteredNetworkTransactions) {
        filteredBytesReceived += transaction.receivedDataLength;
    }
    self.filteredBytesReceived = filteredBytesReceived;
    [self updateFirstSectionHeader];
}

#pragma mark Header

- (void)updateFirstSectionHeader {
    UIView *view = [self.tableView headerViewForSection:0];
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.textLabel.text = [self headerText];
        [headerView setNeedsLayout];
    }
}

- (NSString *)headerText {
    long long bytesReceived = 0;
    NSInteger totalRequests = 0;
    if (self.searchController.isActive) {
        bytesReceived = self.filteredBytesReceived;
        totalRequests = self.filteredNetworkTransactions.count;
    } else {
        bytesReceived = self.bytesReceived;
        totalRequests = self.networkTransactions.count;
    }
    
    NSString *byteCountText = [NSByteCountFormatter
        stringFromByteCount:bytesReceived countStyle:NSByteCountFormatterCountStyleBinary
    ];
    NSString *requestsText = totalRequests == 1 ? @"Request" : @"Requests";
    return [NSString stringWithFormat:@"%@ %@ (%@ received)",
        @(totalRequests), requestsText, byteCountText
    ];
}


#pragma mark - IMLEXGlobalsEntry

+ (NSString *)globalsEntryTitle:(IMLEXGlobalsRow)row {
    return @"📡  Network History";
}

+ (IMLEXGlobalsEntryRowAction)globalsEntryRowAction:(IMLEXGlobalsRow)row {
    return ^(UITableViewController *host) {
        if (IMLEXNetworkObserver.isEnabled) {
            [host.navigationController pushViewController:[
                self globalsEntryViewController:row
            ] animated:YES];
        } else {
            [IMLEXAlert makeAlert:^(IMLEXAlert *make) {
                make.title(@"Network Monitor Disabled");
                make.message(@"You must enable network monitoring to proceed.");
                
                make.button(@"Turn On").handler(^(NSArray<NSString *> *strings) {
                    IMLEXNetworkObserver.enabled = YES;
                    [host.navigationController pushViewController:[
                        self globalsEntryViewController:row
                    ] animated:YES];
                }).cancelStyle();
                make.button(@"Dismiss");
            } showFrom:host];
        }
    };
}

+ (UIViewController *)globalsEntryViewController:(IMLEXGlobalsRow)row {
    UIViewController *controller = [self new];
    controller.title = [self globalsEntryTitle:row];
    return controller;
}


#pragma mark - Notification Handlers

- (void)handleNewTransactionRecordedNotification:(NSNotification *)notification {
    [self tryUpdateTransactions];
}

- (void)tryUpdateTransactions {
    // Don't do any view updating if we aren't in the view hierarchy
    if (!self.viewIfLoaded.window) {
        [self updateTransactions];
        self.pendingReload = YES;
        return;
    }
    
    // Let the previous row insert animation finish before starting a new one to avoid stomping.
    // We'll try calling the method again when the insertion completes,
    // and we properly no-op if there haven't been changes.
    if (self.rowInsertInProgress) {
        return;
    }
    
    if (self.searchController.isActive) {
        [self updateTransactions];
        [self updateSearchResults:self.searchText];
        return;
    }

    NSInteger existingRowCount = self.networkTransactions.count;
    [self updateTransactions];
    NSInteger newRowCount = self.networkTransactions.count;
    NSInteger addedRowCount = newRowCount - existingRowCount;

    if (addedRowCount != 0 && !self.isPresentingSearch) {
        // Insert animation if we're at the top.
        if (self.tableView.contentOffset.y <= 0.0 && addedRowCount > 0) {
            [CATransaction begin];
            
            self.rowInsertInProgress = YES;
            [CATransaction setCompletionBlock:^{
                self.rowInsertInProgress = NO;
                [self tryUpdateTransactions];
            }];

            NSMutableArray<NSIndexPath *> *indexPathsToReload = [NSMutableArray new];
            for (NSInteger row = 0; row < addedRowCount; row++) {
                [indexPathsToReload addObject:[NSIndexPath indexPathForRow:row inSection:0]];
            }
            [self.tableView insertRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationAutomatic];

            [CATransaction commit];
        } else {
            // Maintain the user's position if they've scrolled down.
            CGSize existingContentSize = self.tableView.contentSize;
            [self.tableView reloadData];
            CGFloat contentHeightChange = self.tableView.contentSize.height - existingContentSize.height;
            self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + contentHeightChange);
        }
    }
}

- (void)handleTransactionUpdatedNotification:(NSNotification *)notification {
    [self updateBytesReceived];
    [self updateFilteredBytesReceived];

    IMLEXNetworkTransaction *transaction = notification.userInfo[kIMLEXNetworkRecorderUserInfoTransactionKey];

    // Update both the main table view and search table view if needed.
    for (IMLEXNetworkTransactionTableViewCell *cell in [self.tableView visibleCells]) {
        if ([cell.transaction isEqual:transaction]) {
            // Using -[UITableView reloadRowsAtIndexPaths:withRowAnimation:] is overkill here and kicks off a lot of
            // work that can make the table view somewhat unresponsive when lots of updates are streaming in.
            // We just need to tell the cell that it needs to re-layout.
            [cell setNeedsLayout];
            break;
        }
    }
    [self updateFirstSectionHeader];
}

- (void)handleTransactionsClearedNotification:(NSNotification *)notification {
    [self updateTransactions];
    [self.tableView reloadData];
}

- (void)handleNetworkObserverEnabledStateChangedNotification:(NSNotification *)notification {
    // Update the header, which displays a warning when network debugging is disabled
    [self updateFirstSectionHeader];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchController.isActive ? self.filteredNetworkTransactions.count : self.networkTransactions.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self headerText];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.textLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightSemibold];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IMLEXNetworkTransactionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIMLEXNetworkTransactionCellIdentifier forIndexPath:indexPath];
    cell.transaction = [self transactionAtIndexPath:indexPath];

    // Since we insert from the top, assign background colors bottom up to keep them consistent for each transaction.
    NSInteger totalRows = [tableView numberOfRowsInSection:indexPath.section];
    if ((totalRows - indexPath.row) % 2 == 0) {
        cell.backgroundColor = IMLEXColor.secondaryBackgroundColor;
    } else {
        cell.backgroundColor = IMLEXColor.primaryBackgroundColor;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IMLEXNetworkTransactionDetailTableViewController *detailViewController = [IMLEXNetworkTransactionDetailTableViewController new];
    detailViewController.transaction = [self transactionAtIndexPath:indexPath];
    [self.navigationController pushViewController:detailViewController animated:YES];
}


#pragma mark - Menu Actions

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        NSURLRequest *request = [self transactionAtIndexPath:indexPath].request;
        UIPasteboard.generalPasteboard.string = request.URL.absoluteString ?: @"";
    }
}

#if IMLEX_AT_LEAST_IOS13_SDK

- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point __IOS_AVAILABLE(13.0) {
    NSURLRequest *request = [self transactionAtIndexPath:indexPath].request;
    return [UIContextMenuConfiguration
        configurationWithIdentifier:nil
        previewProvider:nil
        actionProvider:^UIMenu *(NSArray<UIMenuElement *> *suggestedActions) {
            UIAction *copy = [UIAction
                actionWithTitle:@"Copy"
                image:nil
                identifier:nil
                handler:^(__kindof UIAction *action) {
                    UIPasteboard.generalPasteboard.string = request.URL.absoluteString ?: @"";
                }
            ];
            UIAction *blacklist = [UIAction
                actionWithTitle:[NSString stringWithFormat:@"Blacklist '%@'", request.URL.host]
                image:nil
                identifier:nil
                handler:^(__kindof UIAction *action) {
                    NSMutableArray *blacklist =  IMLEXNetworkRecorder.defaultRecorder.hostBlacklist;
                    [blacklist addObject:request.URL.host];
                    [IMLEXNetworkRecorder.defaultRecorder clearBlacklistedTransactions];
                    [IMLEXNetworkRecorder.defaultRecorder synchronizeBlacklist];
                    [self tryUpdateTransactions];
                }
            ];
            return [UIMenu
                menuWithTitle:@"" image:nil identifier:nil
                options:UIMenuOptionsDisplayInline
                children:@[copy, blacklist]
            ];
        }
    ];
}

#endif

- (IMLEXNetworkTransaction *)transactionAtIndexPath:(NSIndexPath *)indexPath {
    return self.searchController.isActive ? self.filteredNetworkTransactions[indexPath.row] : self.networkTransactions[indexPath.row];
}


#pragma mark - Search Bar

- (void)updateSearchResults:(NSString *)searchString {
    if (!searchString.length) {
        self.filteredNetworkTransactions = self.networkTransactions;
        [self.tableView reloadData];
    } else {
        [self onBackgroundQueue:^NSArray *{
            return [self.networkTransactions IMLEX_filtered:^BOOL(IMLEXNetworkTransaction *entry, NSUInteger idx) {
                return [entry.request.URL.absoluteString localizedCaseInsensitiveContainsString:searchString];
            }];
        } thenOnMainQueue:^(NSArray *filteredNetworkTransactions) {
            if ([self.searchText isEqual:searchString]) {
                self.filteredNetworkTransactions = filteredNetworkTransactions;
                [self.tableView reloadData];
            }
        }];
    }
}


#pragma mark UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    self.isPresentingSearch = YES;
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    self.isPresentingSearch = NO;
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    [self.tableView reloadData];
}

@end
