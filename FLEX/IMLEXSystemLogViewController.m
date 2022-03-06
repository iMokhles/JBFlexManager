//
//  IMLEXSystemLogViewController.m
//  IMLEX
//
//  Created by Ryan Olson on 1/19/15.
//  Copyright (c) 2015 f. All rights reserved.
//

#import "IMLEXSystemLogViewController.h"
#import "IMLEXASLLogController.h"
#import "IMLEXOSLogController.h"
#import "IMLEXSystemLogCell.h"
#import "IMLEXMutableListSection.h"
#import "IMLEXUtility.h"
#import "IMLEXColor.h"
#import "IMLEXResources.h"
#import "UIBarButtonItem+IMLEX.h"
#import "NSUserDefaults+IMLEX.h"
#import "IMLEX_fishhook.h"
#import <dlfcn.h>

@interface IMLEXSystemLogViewController ()

@property (nonatomic, readonly) IMLEXMutableListSection<IMLEXSystemLogMessage *> *logMessages;
@property (nonatomic, readonly) id<IMLEXLogController> logController;

@end

static void (*MSHookFunction)(void *symbol, void *replace, void **result);

static BOOL IMLEXDidHookNSLog = NO;
static BOOL IMLEXNSLogHookWorks = NO;

BOOL (*os_log_shim_enabled)(void *addr) = nil;
BOOL (*orig_os_log_shim_enabled)(void *addr) = nil;
static BOOL my_os_log_shim_enabled(void *addr) {
    return NO;
}

@implementation IMLEXSystemLogViewController

#pragma mark - Initialization

+ (void)load {
    // Thanks to @Ram4096 on GitHub for telling me that
    // os_log is conditionally enabled by the SDK version
    void *addr = __builtin_return_address(0);
    void *libsystem_trace = dlopen("/usr/lib/system/libsystem_trace.dylib", RTLD_LAZY);
    os_log_shim_enabled = dlsym(libsystem_trace, "os_log_shim_enabled");
    if (!os_log_shim_enabled) {
        return;
    }

    IMLEXDidHookNSLog = rebind_symbols((struct rebinding[1]) {{
        "os_log_shim_enabled",
        (void *)my_os_log_shim_enabled,
        (void **)&orig_os_log_shim_enabled
    }}, 1) == 0;
    
    if (IMLEXDidHookNSLog && orig_os_log_shim_enabled != nil) {
        // Check if our rebinding worked
        IMLEXNSLogHookWorks = my_os_log_shim_enabled(addr) == NO;
    }
    
    // So, just because we rebind the lazily loaded symbol for
    // this function doesn't mean it's even going to be used.
    // While it seems to be sufficient for the simulator, for
    // whatever reason it is not sufficient on-device. We need
    // to actually hook the function with something like Substrate.
    
    // Check if we have substrate, and if so use that instead
    void *handle = dlopen("/usr/lib/libsubstrate.dylib", RTLD_LAZY);
    if (handle) {
        MSHookFunction = dlsym(handle, "MSHookFunction");
        
        if (MSHookFunction) {
            // Set the hook and check if it worked
            void *unused;
            MSHookFunction(os_log_shim_enabled, my_os_log_shim_enabled, &unused);
            IMLEXNSLogHookWorks = os_log_shim_enabled(addr) == NO;
        }
    }
}

- (id)init {
    return [super initWithStyle:UITableViewStylePlain];
}


#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showsSearchBar = YES;
    self.showSearchBarInitially = NO;

    __weak __typeof(self) weakSelf = self;
    id logHandler = ^(NSArray<IMLEXSystemLogMessage *> *newMessages) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self handleUpdateWithNewMessages:newMessages];
    };
    
    if (IMLEXOSLogAvailable() && !IMLEXNSLogHookWorks) {
        _logController = [IMLEXOSLogController withUpdateHandler:logHandler];
    } else {
        _logController = [IMLEXASLLogController withUpdateHandler:logHandler];
    }

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.title = @"Loading...";
    
    // Toolbar buttons //
    
    UIBarButtonItem *scrollDown = [UIBarButtonItem
        itemWithImage:IMLEXResources.scrollToBottomIcon
        target:self
        action:@selector(scrollToLastRow)
    ];
    UIBarButtonItem *settings = [UIBarButtonItem
        itemWithImage:IMLEXResources.gearIcon
        target:self
        action:@selector(showLogSettings)
    ];
    
    if (IMLEXOSLogAvailable() && !IMLEXNSLogHookWorks) {
        [self addToolbarItems:@[scrollDown, settings]];
    } else {
        [self addToolbarItems:@[scrollDown]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.logController startMonitoring];
}

- (NSArray<IMLEXTableViewSection *> *)makeSections {
    _logMessages = [IMLEXMutableListSection list:@[]
        cellConfiguration:^(IMLEXSystemLogCell *cell, IMLEXSystemLogMessage *message, NSInteger row) {
            cell.logMessage = message;
            cell.highlightedText = self.filterText;
            
            if (row % 2 == 0) {
                cell.backgroundColor = IMLEXColor.primaryBackgroundColor;
            } else {
                cell.backgroundColor = IMLEXColor.secondaryBackgroundColor;
            }
        } filterMatcher:^BOOL(NSString *filterText, IMLEXSystemLogMessage *message) {
            NSString *displayedText = [IMLEXSystemLogCell displayedTextForLogMessage:message];
            return [displayedText localizedCaseInsensitiveContainsString:filterText];
        }
    ];
    
    self.logMessages.cellRegistrationMapping = @{
        kIMLEXSystemLogCellIdentifier : [IMLEXSystemLogCell class]
    };
    
    return @[self.logMessages];
}

- (NSArray<IMLEXTableViewSection *> *)nonemptySections {
    return @[self.logMessages];
}


#pragma mark - Private

- (void)handleUpdateWithNewMessages:(NSArray<IMLEXSystemLogMessage *> *)newMessages {
    self.title = [self.class globalsEntryTitle:IMLEXGlobalsRowSystemLog];

    [self.logMessages mutate:^(NSMutableArray *list) {
        [list addObjectsFromArray:newMessages];
    }];

    // "Follow" the log as new messages stream in if we were previously near the bottom.
    BOOL wasNearBottom = self.tableView.contentOffset.y >= self.tableView.contentSize.height - self.tableView.frame.size.height - 100.0;
    [self reloadData];
    if (wasNearBottom) {
        [self scrollToLastRow];
    }
}

- (void)scrollToLastRow {
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
    if (numberOfRows > 0) {
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:numberOfRows - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)showLogSettings {
    IMLEXOSLogController *logController = (IMLEXOSLogController *)self.logController;
    BOOL persistent = NSUserDefaults.standardUserDefaults.IMLEX_cacheOSLogMessages;
    NSString *toggle = persistent ? @"Disable" : @"Enable";
    NSString *title = [@"Persistent logging: " stringByAppendingString:persistent ? @"ON" : @"OFF"];
    NSString *body = @"In iOS 10 and up, ASL is gone. The OS Log API is much more limited. "
    "To get as close to the old behavior as possible, logs must be collected manually at launch and stored.\n\n"
    "Turn this feature on only when you need it.";

    [IMLEXAlert makeAlert:^(IMLEXAlert *make) {
        make.title(title).message(body).button(toggle).handler(^(NSArray<NSString *> *strings) {
            NSUserDefaults.standardUserDefaults.IMLEX_cacheOSLogMessages = !persistent;
            logController.persistent = !persistent;
            [logController.messages addObjectsFromArray:self.logMessages.list];
        });
        make.button(@"Dismiss").cancelStyle();
    } showFrom:self];
}


#pragma mark - IMLEXGlobalsEntry

+ (NSString *)globalsEntryTitle:(IMLEXGlobalsRow)row {
    return @"⚠️  System Log";
}

+ (UIViewController *)globalsEntryViewController:(IMLEXGlobalsRow)row {
    return [self new];
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    IMLEXSystemLogMessage *logMessage = self.logMessages.filteredList[indexPath.row];
    return [IMLEXSystemLogCell preferredHeightForLogMessage:logMessage inWidth:self.tableView.bounds.size.width];
}


#pragma mark - Copy on long press

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        // We usually only want to copy the log message itself, not any metadata associated with it.
        UIPasteboard.generalPasteboard.string = self.logMessages.filteredList[indexPath.row].messageText;
    }
}

@end
