//
//  IMLEXAddressExplorerCoordinator.m
//  IMLEX
//
//  Created by Tanner Bennett on 7/10/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXAddressExplorerCoordinator.h"
#import "IMLEXGlobalsViewController.h"
#import "IMLEXObjectExplorerFactory.h"
#import "IMLEXObjectExplorerViewController.h"
#import "IMLEXRuntimeUtility.h"
#import "IMLEXUtility.h"

@interface UITableViewController (IMLEXAddressExploration)
- (void)deselectSelectedRow;
- (void)tryExploreAddress:(NSString *)addressString safely:(BOOL)safely;
@end

@implementation IMLEXAddressExplorerCoordinator

#pragma mark - IMLEXGlobalsEntry

+ (NSString *)globalsEntryTitle:(IMLEXGlobalsRow)row {
    return @"🔎  Address Explorer";
}

+ (IMLEXGlobalsEntryRowAction)globalsEntryRowAction:(IMLEXGlobalsRow)row {
    return ^(UITableViewController *host) {

        NSString *title = @"Explore Object at Address";
        NSString *message = @"Paste a hexadecimal address below, starting with '0x'. "
        "Use the unsafe option if you need to bypass pointer validation, "
        "but know that it may crash the app if the address is invalid.";

        [IMLEXAlert makeAlert:^(IMLEXAlert *make) {
            make.title(title).message(message);
            make.configuredTextField(^(UITextField *textField) {
                NSString *copied = UIPasteboard.generalPasteboard.string;
                textField.placeholder = @"0x00000070deadbeef";
                // Go ahead and paste our clipboard if we have an address copied
                if ([copied hasPrefix:@"0x"]) {
                    textField.text = copied;
                    [textField selectAll:nil];
                }
            });
            make.button(@"Explore").handler(^(NSArray<NSString *> *strings) {
                [host tryExploreAddress:strings.firstObject safely:YES];
            });
            make.button(@"Unsafe Explore").destructiveStyle().handler(^(NSArray *strings) {
                [host tryExploreAddress:strings.firstObject safely:NO];
            });
            make.button(@"Cancel").cancelStyle();
        } showFrom:host];

    };
}

@end

@implementation UITableViewController (IMLEXAddressExploration)

- (void)deselectSelectedRow {
    NSIndexPath *selected = self.tableView.indexPathForSelectedRow;
    [self.tableView deselectRowAtIndexPath:selected animated:YES];
}

- (void)tryExploreAddress:(NSString *)addressString safely:(BOOL)safely {
    NSScanner *scanner = [NSScanner scannerWithString:addressString];
    unsigned long long hexValue = 0;
    BOOL didParseAddress = [scanner scanHexLongLong:&hexValue];
    const void *pointerValue = (void *)hexValue;

    NSString *error = nil;

    if (didParseAddress) {
        if (safely && ![IMLEXRuntimeUtility pointerIsValidObjcObject:pointerValue]) {
            error = @"The given address is unlikely to be a valid object.";
        }
    } else {
        error = @"Malformed address. Make sure it's not too long and starts with '0x'.";
    }

    if (!error) {
        id object = (__bridge id)pointerValue;
        IMLEXObjectExplorerViewController *explorer = [IMLEXObjectExplorerFactory explorerViewControllerForObject:object];
        [self.navigationController pushViewController:explorer animated:YES];
    } else {
        [IMLEXAlert showAlert:@"Uh-oh" message:error from:self];
        [self deselectSelectedRow];
    }
}

@end
