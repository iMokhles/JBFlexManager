//
//  IMLEXManager.m
//  Flipboard
//
//  Created by Ryan Olson on 4/4/14.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXManager.h"
#import "IMLEXUtility.h"
#import "IMLEXExplorerViewController.h"
#import "IMLEXWindow.h"
#import "IMLEXObjectExplorerViewController.h"
#import "IMLEXFileBrowserTableViewController.h"

@interface IMLEXManager () <IMLEXWindowEventDelegate, IMLEXExplorerViewControllerDelegate>

@property (nonatomic, readonly, getter=isHidden) BOOL hidden;

@property (nonatomic) IMLEXWindow *explorerWindow;
@property (nonatomic) IMLEXExplorerViewController *explorerViewController;

@property (nonatomic, readonly) NSMutableArray<IMLEXGlobalsEntry *> *userGlobalEntries;
@property (nonatomic, readonly) NSMutableDictionary<NSString *, IMLEXCustomContentViewerFuture> *customContentTypeViewers;

@end

@implementation IMLEXManager

+ (instancetype)sharedManager {
    static IMLEXManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [self new];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _userGlobalEntries = [NSMutableArray new];
        _customContentTypeViewers = [NSMutableDictionary new];
    }
    return self;
}

- (IMLEXWindow *)explorerWindow {
    NSAssert(NSThread.isMainThread, @"You must use %@ from the main thread only.", NSStringFromClass([self class]));
    
    if (!_explorerWindow) {
        _explorerWindow = [[IMLEXWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        _explorerWindow.eventDelegate = self;
        _explorerWindow.rootViewController = self.explorerViewController;
    }
    
    return _explorerWindow;
}

- (IMLEXExplorerViewController *)explorerViewController {
    if (!_explorerViewController) {
        _explorerViewController = [IMLEXExplorerViewController new];
        _explorerViewController.delegate = self;
    }

    return _explorerViewController;
}

- (void)showExplorer {
    UIWindow *IMLEX = self.explorerWindow;
    IMLEX.hidden = NO;
#if IMLEX_AT_LEAST_IOS13_SDK
    if (@available(iOS 13.0, *)) {
        // Only look for a new scene if we don't have one
        if (!IMLEX.windowScene) {
            IMLEX.windowScene = IMLEXUtility.activeScene;
        }
    }
#endif
}

- (void)hideExplorer {
    self.explorerWindow.hidden = YES;
}

- (void)toggleExplorer {
    if (self.explorerWindow.isHidden) {
        [self showExplorer];
    } else {
        [self hideExplorer];
    }
}

- (void)showExplorerFromScene:(UIWindowScene *)scene {
    #if IMLEX_AT_LEAST_IOS13_SDK
    if (@available(iOS 13.0, *)) {
        self.explorerWindow.windowScene = scene;
    }
    #endif
    self.explorerWindow.hidden = NO;
}

- (BOOL)isHidden {
    return self.explorerWindow.isHidden;
}

- (IMLEXExplorerToolbar *)toolbar {
    return self.explorerViewController.explorerToolbar;
}


#pragma mark - IMLEXWindowEventDelegate

- (BOOL)shouldHandleTouchAtPoint:(CGPoint)pointInWindow {
    // Ask the explorer view controller
    return [self.explorerViewController shouldReceiveTouchAtWindowPoint:pointInWindow];
}

- (BOOL)canBecomeKeyWindow {
    // Only when the explorer view controller wants it because
    // it needs to accept key input & affect the status bar.
    return self.explorerViewController.wantsWindowToBecomeKey;
}


#pragma mark - IMLEXExplorerViewControllerDelegate

- (void)explorerViewControllerDidFinish:(IMLEXExplorerViewController *)explorerViewController {
    [self hideExplorer];
}

@end
