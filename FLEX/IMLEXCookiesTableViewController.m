//
//  IMLEXCookiesTableViewController.m
//  IMLEX
//
//  Created by Rich Robinson on 19/10/2015.
//  Copyright © 2015 Flipboard. All rights reserved.
//

#import "IMLEXCookiesTableViewController.h"
#import "IMLEXObjectExplorerFactory.h"
#import "IMLEXMutableListSection.h"
#import "IMLEXUtility.h"

@interface IMLEXCookiesTableViewController ()
@property (nonatomic, readonly) IMLEXMutableListSection<NSHTTPCookie *> *cookies;
@property (nonatomic) NSString *headerTitle;
@end

@implementation IMLEXCookiesTableViewController

#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Cookies";
}

- (NSArray<IMLEXTableViewSection *> *)makeSections {
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc]
        initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)
    ];
    NSArray *cookies = [NSHTTPCookieStorage.sharedHTTPCookieStorage.cookies
       sortedArrayUsingDescriptors:@[nameSortDescriptor]
    ];
    
    _cookies = [IMLEXMutableListSection list:cookies
        cellConfiguration:^(UITableViewCell *cell, NSHTTPCookie *cookie, NSInteger row) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [cookie.name stringByAppendingFormat:@" (%@)", cookie.value];
            cell.detailTextLabel.text = [cookie.domain stringByAppendingFormat:@" — %@", cookie.path];
        } filterMatcher:^BOOL(NSString *filterText, NSHTTPCookie *cookie) {
            return [cookie.name localizedCaseInsensitiveContainsString:filterText] ||
                [cookie.value localizedCaseInsensitiveContainsString:filterText] ||
                [cookie.domain localizedCaseInsensitiveContainsString:filterText] ||
                [cookie.path localizedCaseInsensitiveContainsString:filterText];
        }
    ];
    
    self.cookies.selectionHandler = ^(UIViewController *host, NSHTTPCookie *cookie) {
        [host.navigationController pushViewController:[
            IMLEXObjectExplorerFactory explorerViewControllerForObject:cookie
        ] animated:YES];
    };
    
    return @[self.cookies];
}

- (void)reloadData {
    self.headerTitle = [NSString stringWithFormat:
        @"%@ cookies", @(self.cookies.filteredList.count)
    ];
    [super reloadData];
}

#pragma mark - IMLEXGlobalsEntry

+ (NSString *)globalsEntryTitle:(IMLEXGlobalsRow)row {
    return @"🍪  Cookies";
}

+ (UIViewController *)globalsEntryViewController:(IMLEXGlobalsRow)row {
    return [self new];
}

@end
