//
//  IMLEXGlobalsViewController.h
//  Flipboard
//
//  Created by Ryan Olson on 2014-05-03.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXFilteringTableViewController.h"
@protocol IMLEXGlobalsTableViewControllerDelegate;

typedef NS_ENUM(NSUInteger, IMLEXGlobalsSectionKind) {
    /// NSProcessInfo, Network history, system log,
    /// heap, address explorer, libraries, app classes
    IMLEXGlobalsSectionProcessAndEvents,
    /// Browse container, browse bundle, NSBundle.main,
    /// NSUserDefaults.standard, UIApplication,
    /// app delegate, key window, root VC, cookies
    IMLEXGlobalsSectionAppShortcuts,
    /// UIPasteBoard.general, UIScreen, UIDevice
    IMLEXGlobalsSectionMisc,
    IMLEXGlobalsSectionCustom,
    IMLEXGlobalsSectionCount
};

@interface IMLEXGlobalsViewController : IMLEXFilteringTableViewController

@end
