//
//  IMLEXObjectExplorerFactory.m
//  Flipboard
//
//  Created by Ryan Olson on 5/15/14.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXObjectExplorerFactory.h"
#import "IMLEXGlobalsViewController.h"
#import "IMLEXClassShortcuts.h"
#import "IMLEXViewShortcuts.h"
#import "IMLEXViewControllerShortcuts.h"
#import "IMLEXImageShortcuts.h"
#import "IMLEXLayerShortcuts.h"
#import "IMLEXColorPreviewSection.h"
#import "IMLEXDefaultsContentSection.h"
#import "IMLEXBundleShortcuts.h"
#import "IMLEXBlockShortcuts.h"
#import "IMLEXUtility.h"

@implementation IMLEXObjectExplorerFactory
static NSMutableDictionary<Class, Class> *classesToRegisteredSections = nil;

+ (void)initialize {
    if (self == [IMLEXObjectExplorerFactory class]) {
        #define ClassKey(name) (Class<NSCopying>)[name class]
        #define ClassKeyByName(str) (Class<NSCopying>)NSClassFromString(@ #str)
        #define MetaclassKey(meta) (Class<NSCopying>)object_getClass([meta class])
        classesToRegisteredSections = [NSMutableDictionary dictionaryWithDictionary:@{
            MetaclassKey(NSObject)     : [IMLEXClassShortcuts class],
            ClassKey(NSArray)          : [IMLEXCollectionContentSection class],
            ClassKey(NSSet)            : [IMLEXCollectionContentSection class],
            ClassKey(NSDictionary)     : [IMLEXCollectionContentSection class],
            ClassKey(NSOrderedSet)     : [IMLEXCollectionContentSection class],
            ClassKey(NSUserDefaults)   : [IMLEXDefaultsContentSection class],
            ClassKey(UIViewController) : [IMLEXViewControllerShortcuts class],
            ClassKey(UIView)           : [IMLEXViewShortcuts class],
            ClassKey(UIImage)          : [IMLEXImageShortcuts class],
            ClassKey(CALayer)          : [IMLEXLayerShortcuts class],
            ClassKey(UIColor)          : [IMLEXColorPreviewSection class],
            ClassKey(NSBundle)         : [IMLEXBundleShortcuts class],
            ClassKeyByName(NSBlock)    : [IMLEXBlockShortcuts class],
        }];
        #undef ClassKey
        #undef ClassKeyByName
        #undef MetaclassKey
    }
}

+ (IMLEXObjectExplorerViewController *)explorerViewControllerForObject:(id)object {
    // Can't explore nil
    if (!object) {
        return nil;
    }

    // If we're given an object, this will look up it's class hierarchy
    // until it finds a registration. This will work for KVC classes,
    // since they are children of the original class, and not siblings.
    // If we are given an object, object_getClass will return a metaclass,
    // and the same thing will happen. IMLEXClassShortcuts is the default
    // shortcut section for NSObject.
    //
    // TODO: rename it to IMLEXNSObjectShortcuts or something?
    Class sectionClass = nil;
    Class cls = object_getClass(object);
    do {
        sectionClass = classesToRegisteredSections[(Class<NSCopying>)cls];
    } while (!sectionClass && (cls = [cls superclass]));

    if (!sectionClass) {
        sectionClass = [IMLEXShortcutsSection class];
    }

    return [IMLEXObjectExplorerViewController
        exploringObject:object
        customSection:[sectionClass forObject:object]
    ];
}

+ (void)registerExplorerSection:(Class)explorerClass forClass:(Class)objectClass {
    classesToRegisteredSections[(Class<NSCopying>)objectClass] = explorerClass;
}

#pragma mark - IMLEXGlobalsEntry

+ (NSString *)globalsEntryTitle:(IMLEXGlobalsRow)row  {
    switch (row) {
        case IMLEXGlobalsRowAppDelegate:
            return @"🎟  App Delegate";
        case IMLEXGlobalsRowKeyWindow:
            return @"🔑  Key Window";
        case IMLEXGlobalsRowRootViewController:
            return @"🌴  Root View Controller";
        case IMLEXGlobalsRowProcessInfo:
            return @"🚦  NSProcessInfo.processInfo";
        case IMLEXGlobalsRowUserDefaults:
            return @"💾  Preferences";
        case IMLEXGlobalsRowMainBundle:
            return @"📦  NSBundle.mainBundle";
        case IMLEXGlobalsRowApplication:
            return @"🚀  UIApplication.sharedApplication";
        case IMLEXGlobalsRowMainScreen:
            return @"💻  UIScreen.mainScreen";
        case IMLEXGlobalsRowCurrentDevice:
            return @"📱  UIDevice.currentDevice";
        case IMLEXGlobalsRowPasteboard:
            return @"📋  UIPasteboard.generalPasteboard";
        case IMLEXGlobalsRowURLSession:
            return @"📡  NSURLSession.sharedSession";
        case IMLEXGlobalsRowURLCache:
            return @"⏳  NSURLCache.sharedURLCache";
        case IMLEXGlobalsRowNotificationCenter:
            return @"🔔  NSNotificationCenter.defaultCenter";
        case IMLEXGlobalsRowMenuController:
            return @"📎  UIMenuController.sharedMenuController";
        case IMLEXGlobalsRowFileManager:
            return @"🗄  NSFileManager.defaultManager";
        case IMLEXGlobalsRowTimeZone:
            return @"🌎  NSTimeZone.systemTimeZone";
        case IMLEXGlobalsRowLocale:
            return @"🗣  NSLocale.currentLocale";
        case IMLEXGlobalsRowCalendar:
            return @"📅  NSCalendar.currentCalendar";
        case IMLEXGlobalsRowMainRunLoop:
            return @"🏃🏻‍♂️  NSRunLoop.mainRunLoop";
        case IMLEXGlobalsRowMainThread:
            return @"🧵  NSThread.mainThread";
        case IMLEXGlobalsRowOperationQueue:
            return @"📚  NSOperationQueue.mainQueue";
        default: return nil;
    }
}

+ (UIViewController *)globalsEntryViewController:(IMLEXGlobalsRow)row  {
    switch (row) {
        case IMLEXGlobalsRowAppDelegate: {
            id<UIApplicationDelegate> appDelegate = UIApplication.sharedApplication.delegate;
            return [self explorerViewControllerForObject:appDelegate];
        }
        case IMLEXGlobalsRowProcessInfo:
            return [self explorerViewControllerForObject:NSProcessInfo.processInfo];
        case IMLEXGlobalsRowUserDefaults:
            return [self explorerViewControllerForObject:NSUserDefaults.standardUserDefaults];
        case IMLEXGlobalsRowMainBundle:
            return [self explorerViewControllerForObject:NSBundle.mainBundle];
        case IMLEXGlobalsRowApplication:
            return [self explorerViewControllerForObject:UIApplication.sharedApplication];
        case IMLEXGlobalsRowMainScreen:
            return [self explorerViewControllerForObject:UIScreen.mainScreen];
        case IMLEXGlobalsRowCurrentDevice:
            return [self explorerViewControllerForObject:UIDevice.currentDevice];
        case IMLEXGlobalsRowPasteboard:
            return [self explorerViewControllerForObject:UIPasteboard.generalPasteboard];
            case IMLEXGlobalsRowURLSession:
            return [self explorerViewControllerForObject:NSURLSession.sharedSession];
        case IMLEXGlobalsRowURLCache:
            return [self explorerViewControllerForObject:NSURLCache.sharedURLCache];
        case IMLEXGlobalsRowNotificationCenter:
            return [self explorerViewControllerForObject:NSNotificationCenter.defaultCenter];
        case IMLEXGlobalsRowMenuController:
            return [self explorerViewControllerForObject:UIMenuController.sharedMenuController];
        case IMLEXGlobalsRowFileManager:
            return [self explorerViewControllerForObject:NSFileManager.defaultManager];
        case IMLEXGlobalsRowTimeZone:
            return [self explorerViewControllerForObject:NSTimeZone.systemTimeZone];
        case IMLEXGlobalsRowLocale:
            return [self explorerViewControllerForObject:NSLocale.currentLocale];
        case IMLEXGlobalsRowCalendar:
            return [self explorerViewControllerForObject:NSCalendar.currentCalendar];
        case IMLEXGlobalsRowMainRunLoop:
            return [self explorerViewControllerForObject:NSRunLoop.mainRunLoop];
        case IMLEXGlobalsRowMainThread:
            return [self explorerViewControllerForObject:NSThread.mainThread];
        case IMLEXGlobalsRowOperationQueue:
            return [self explorerViewControllerForObject:NSOperationQueue.mainQueue];
            
        case IMLEXGlobalsRowKeyWindow:
            return [IMLEXObjectExplorerFactory
                explorerViewControllerForObject:IMLEXUtility.appKeyWindow
            ];
        case IMLEXGlobalsRowRootViewController: {
            id<UIApplicationDelegate> delegate = UIApplication.sharedApplication.delegate;
            if ([delegate respondsToSelector:@selector(window)]) {
                return [self explorerViewControllerForObject:delegate.window.rootViewController];
            }

            return nil;
        }
        default: return nil;
    }
}

+ (IMLEXGlobalsEntryRowAction)globalsEntryRowAction:(IMLEXGlobalsRow)row {
    switch (row) {
        case IMLEXGlobalsRowRootViewController: {
            // Check if the app delegate responds to -window. If not, present an alert
            return ^(UITableViewController *host) {
                id<UIApplicationDelegate> delegate = UIApplication.sharedApplication.delegate;
                if ([delegate respondsToSelector:@selector(window)]) {
                    UIViewController *explorer = [self explorerViewControllerForObject:
                        delegate.window.rootViewController
                    ];
                    [host.navigationController pushViewController:explorer animated:YES];
                } else {
                    NSString *msg = @"The app delegate doesn't respond to -window";
                    [IMLEXAlert showAlert:@":(" message:msg from:host];
                }
            };
        }
        default: return nil;
    }
}

@end
