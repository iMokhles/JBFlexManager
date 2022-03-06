//
//  IMLEXGlobalsEntry.h
//  IMLEX
//
//  Created by Javier Soto on 7/26/14.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, IMLEXGlobalsRow) {
    IMLEXGlobalsRowProcessInfo,
    IMLEXGlobalsRowNetworkHistory,
    IMLEXGlobalsRowSystemLog,
    IMLEXGlobalsRowLiveObjects,
    IMLEXGlobalsRowAddressInspector,
    IMLEXGlobalsRowCookies,
    IMLEXGlobalsRowBrowseRuntime,
    IMLEXGlobalsRowAppKeychainItems,
    IMLEXGlobalsRowAppDelegate,
    IMLEXGlobalsRowRootViewController,
    IMLEXGlobalsRowUserDefaults,
    IMLEXGlobalsRowMainBundle,
    IMLEXGlobalsRowBrowseBundle,
    IMLEXGlobalsRowBrowseContainer,
    IMLEXGlobalsRowApplication,
    IMLEXGlobalsRowKeyWindow,
    IMLEXGlobalsRowMainScreen,
    IMLEXGlobalsRowCurrentDevice,
    IMLEXGlobalsRowPasteboard,
    IMLEXGlobalsRowURLSession,
    IMLEXGlobalsRowURLCache,
    IMLEXGlobalsRowNotificationCenter,
    IMLEXGlobalsRowMenuController,
    IMLEXGlobalsRowFileManager,
    IMLEXGlobalsRowTimeZone,
    IMLEXGlobalsRowLocale,
    IMLEXGlobalsRowCalendar,
    IMLEXGlobalsRowMainRunLoop,
    IMLEXGlobalsRowMainThread,
    IMLEXGlobalsRowOperationQueue,
    IMLEXGlobalsRowCount
};

typedef NSString * _Nonnull (^IMLEXGlobalsEntryNameFuture)(void);
/// Simply return a view controller to be pushed on the navigation stack
typedef UIViewController * _Nullable (^IMLEXGlobalsEntryViewControllerFuture)(void);
/// Do something like present an alert, then use the host
/// view controller to present or push another view controller.
typedef void (^IMLEXGlobalsEntryRowAction)(__kindof UITableViewController * _Nonnull host);

/// For view controllers to conform to to indicate they support being used
/// in the globals table view controller. These methods help create concrete entries.
///
/// Previously, the concrete entries relied on "futures" for the view controller and title.
/// With this protocol, the conforming class itself can act as a future, since the methods
/// will not be invoked until the title and view controller / row action are needed.
///
/// Entries can implement \c globalsEntryViewController: to unconditionally provide a
/// view controller, or \c globalsEntryRowAction: to conditionally provide one and
/// perform some action (such as present an alert) if no view controller is available,
/// or both if there is a mix of rows where some are guaranteed to work and some are not.
/// Where both are implemented, \c globalsEntryRowAction: takes precedence; if it returns
/// an action for the requested row, that will be used instead of \c globalsEntryViewController:
@protocol IMLEXGlobalsEntry <NSObject>

+ (NSString *)globalsEntryTitle:(IMLEXGlobalsRow)row;

// Must respond to at least one of the below.
// globalsEntryRowAction: takes precedence if both are implemented.
@optional

+ (nullable UIViewController *)globalsEntryViewController:(IMLEXGlobalsRow)row;
+ (nullable IMLEXGlobalsEntryRowAction)globalsEntryRowAction:(IMLEXGlobalsRow)row;

@end

@interface IMLEXGlobalsEntry : NSObject

@property (nonatomic, readonly, nonnull)  IMLEXGlobalsEntryNameFuture entryNameFuture;
@property (nonatomic, readonly, nullable) IMLEXGlobalsEntryViewControllerFuture viewControllerFuture;
@property (nonatomic, readonly, nullable) IMLEXGlobalsEntryRowAction rowAction;

+ (instancetype)entryWithEntry:(Class<IMLEXGlobalsEntry>)entry row:(IMLEXGlobalsRow)row;

+ (instancetype)entryWithNameFuture:(IMLEXGlobalsEntryNameFuture)nameFuture
               viewControllerFuture:(IMLEXGlobalsEntryViewControllerFuture)viewControllerFuture;

+ (instancetype)entryWithNameFuture:(IMLEXGlobalsEntryNameFuture)nameFuture
                             action:(IMLEXGlobalsEntryRowAction)rowSelectedAction;

@end


@interface NSObject (IMLEXGlobalsEntry)

/// @return The result of passing self to +[IMLEXGlobalsEntry entryWithEntry:]
/// if the class conforms to IMLEXGlobalsEntry, else, nil.
+ (nullable IMLEXGlobalsEntry *)IMLEX_concreteGlobalsEntry:(IMLEXGlobalsRow)row;

@end

NS_ASSUME_NONNULL_END
