//
//  IMLEXGlobalsViewController.m
//  Flipboard
//
//  Created by Ryan Olson on 2014-05-03.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXGlobalsViewController.h"
#import "IMLEXUtility.h"
#import "IMLEXRuntimeUtility.h"
#import "IMLEXObjcRuntimeViewController.h"
#import "IMLEXKeychainTableViewController.h"
#import "IMLEXObjectExplorerViewController.h"
#import "IMLEXObjectExplorerFactory.h"
#import "IMLEXLiveObjectsTableViewController.h"
#import "IMLEXFileBrowserTableViewController.h"
#import "IMLEXCookiesTableViewController.h"
#import "IMLEXGlobalsEntry.h"
#import "IMLEXManager+Private.h"
#import "IMLEXSystemLogViewController.h"
#import "IMLEXNetworkMITMViewController.h"
#import "IMLEXAddressExplorerCoordinator.h"
#import "IMLEXGlobalsSection.h"
#import "UIBarButtonItem+IMLEX.h"

@interface IMLEXGlobalsViewController ()
/// Only displayed sections of the table view; empty sections are purged from this array.
@property (nonatomic) NSArray<IMLEXGlobalsSection *> *sections;
/// Every section in the table view, regardless of whether or not a section is empty.
@property (nonatomic, readonly) NSArray<IMLEXGlobalsSection *> *allSections;
@property (nonatomic, readonly) BOOL manuallyDeselectOnAppear;
@end

@implementation IMLEXGlobalsViewController
@dynamic sections, allSections;

#pragma mark - Initialization

+ (NSString *)globalsTitleForSection:(IMLEXGlobalsSectionKind)section {
    switch (section) {
        case IMLEXGlobalsSectionProcessAndEvents:
            return @"Process and Events";
        case IMLEXGlobalsSectionAppShortcuts:
            return @"App Shortcuts";
        case IMLEXGlobalsSectionMisc:
            return @"Miscellaneous";
        case IMLEXGlobalsSectionCustom:
            return @"Custom Additions";

        default:
            @throw NSInternalInconsistencyException;
    }
}

+ (IMLEXGlobalsEntry *)globalsEntryForRow:(IMLEXGlobalsRow)row {
    switch (row) {
        case IMLEXGlobalsRowAppKeychainItems:
            return [IMLEXKeychainTableViewController IMLEX_concreteGlobalsEntry:row];
        case IMLEXGlobalsRowAddressInspector:
            return [IMLEXAddressExplorerCoordinator IMLEX_concreteGlobalsEntry:row];
        case IMLEXGlobalsRowBrowseRuntime:
            return [IMLEXObjcRuntimeViewController IMLEX_concreteGlobalsEntry:row];
        case IMLEXGlobalsRowLiveObjects:
            return [IMLEXLiveObjectsTableViewController IMLEX_concreteGlobalsEntry:row];
        case IMLEXGlobalsRowCookies:
            return [IMLEXCookiesTableViewController IMLEX_concreteGlobalsEntry:row];
        case IMLEXGlobalsRowBrowseBundle:
        case IMLEXGlobalsRowBrowseContainer:
            return [IMLEXFileBrowserTableViewController IMLEX_concreteGlobalsEntry:row];
        case IMLEXGlobalsRowSystemLog:
            return [IMLEXSystemLogViewController IMLEX_concreteGlobalsEntry:row];
        case IMLEXGlobalsRowNetworkHistory:
            return [IMLEXNetworkMITMViewController IMLEX_concreteGlobalsEntry:row];
        case IMLEXGlobalsRowKeyWindow:
        case IMLEXGlobalsRowRootViewController:
        case IMLEXGlobalsRowProcessInfo:
        case IMLEXGlobalsRowAppDelegate:
        case IMLEXGlobalsRowUserDefaults:
        case IMLEXGlobalsRowMainBundle:
        case IMLEXGlobalsRowApplication:
        case IMLEXGlobalsRowMainScreen:
        case IMLEXGlobalsRowCurrentDevice:
        case IMLEXGlobalsRowPasteboard:
        case IMLEXGlobalsRowURLSession:
        case IMLEXGlobalsRowURLCache:
        case IMLEXGlobalsRowNotificationCenter:
        case IMLEXGlobalsRowMenuController:
        case IMLEXGlobalsRowFileManager:
        case IMLEXGlobalsRowTimeZone:
        case IMLEXGlobalsRowLocale:
        case IMLEXGlobalsRowCalendar:
        case IMLEXGlobalsRowMainRunLoop:
        case IMLEXGlobalsRowMainThread:
        case IMLEXGlobalsRowOperationQueue:
            return [IMLEXObjectExplorerFactory IMLEX_concreteGlobalsEntry:row];

        default:
            @throw [NSException
                exceptionWithName:NSInternalInconsistencyException
                reason:@"Missing globals case in switch" userInfo:nil
            ];
    }
}

+ (NSArray<IMLEXGlobalsSection *> *)defaultGlobalSections {
    static NSArray<IMLEXGlobalsSection *> *sections = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *rowsBySection = @[
            @[
                [self globalsEntryForRow:IMLEXGlobalsRowNetworkHistory],
                [self globalsEntryForRow:IMLEXGlobalsRowSystemLog],
                [self globalsEntryForRow:IMLEXGlobalsRowProcessInfo],
                [self globalsEntryForRow:IMLEXGlobalsRowLiveObjects],
                [self globalsEntryForRow:IMLEXGlobalsRowAddressInspector],
                [self globalsEntryForRow:IMLEXGlobalsRowBrowseRuntime],
            ],
            @[ // IMLEXGlobalsSectionAppShortcuts
                [self globalsEntryForRow:IMLEXGlobalsRowBrowseBundle],
                [self globalsEntryForRow:IMLEXGlobalsRowBrowseContainer],
                [self globalsEntryForRow:IMLEXGlobalsRowMainBundle],
                [self globalsEntryForRow:IMLEXGlobalsRowUserDefaults],
                [self globalsEntryForRow:IMLEXGlobalsRowAppKeychainItems],
                [self globalsEntryForRow:IMLEXGlobalsRowApplication],
                [self globalsEntryForRow:IMLEXGlobalsRowAppDelegate],
                [self globalsEntryForRow:IMLEXGlobalsRowKeyWindow],
                [self globalsEntryForRow:IMLEXGlobalsRowRootViewController],
                [self globalsEntryForRow:IMLEXGlobalsRowCookies],
            ],
            @[ // IMLEXGlobalsSectionMisc
                [self globalsEntryForRow:IMLEXGlobalsRowPasteboard],
                [self globalsEntryForRow:IMLEXGlobalsRowMainScreen],
                [self globalsEntryForRow:IMLEXGlobalsRowCurrentDevice],
                [self globalsEntryForRow:IMLEXGlobalsRowURLSession],
                [self globalsEntryForRow:IMLEXGlobalsRowURLCache],
                [self globalsEntryForRow:IMLEXGlobalsRowNotificationCenter],
                [self globalsEntryForRow:IMLEXGlobalsRowMenuController],
                [self globalsEntryForRow:IMLEXGlobalsRowFileManager],
                [self globalsEntryForRow:IMLEXGlobalsRowTimeZone],
                [self globalsEntryForRow:IMLEXGlobalsRowLocale],
                [self globalsEntryForRow:IMLEXGlobalsRowCalendar],
                [self globalsEntryForRow:IMLEXGlobalsRowMainRunLoop],
                [self globalsEntryForRow:IMLEXGlobalsRowMainThread],
                [self globalsEntryForRow:IMLEXGlobalsRowOperationQueue],
            ]
        ];
        
        sections = [NSArray IMLEX_forEachUpTo:rowsBySection.count map:^IMLEXGlobalsSection *(NSUInteger i) {
            NSString *title = [self globalsTitleForSection:i];
            return [IMLEXGlobalsSection title:title rows:rowsBySection[i]];
        }];
    });
    
    return sections;
}


#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"💪  IMLEX";
    self.showsSearchBar = YES;
    self.searchBarDebounceInterval = kIMLEXDebounceInstant;
    self.navigationItem.backBarButtonItem = [UIBarButtonItem backItemWithTitle:@"Back"];
    
    _manuallyDeselectOnAppear = NSProcessInfo.processInfo.operatingSystemVersion.majorVersion < 10;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self disableToolbar];
    
    if (self.manuallyDeselectOnAppear) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

- (NSArray<IMLEXGlobalsSection *> *)makeSections {
    NSArray *sections = [self.class defaultGlobalSections];
    
    // Do we have custom sections to add?
    if (IMLEXManager.sharedManager.userGlobalEntries.count) {
        NSString *title = [[self class] globalsTitleForSection:IMLEXGlobalsSectionCustom];
        IMLEXGlobalsSection *custom = [IMLEXGlobalsSection
            title:title
            rows:IMLEXManager.sharedManager.userGlobalEntries
        ];
        sections = [sections arrayByAddingObject:custom];
    }
    
    return sections;
}

@end
