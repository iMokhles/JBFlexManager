//
//  IMLEXExplorerViewController.h
//  Flipboard
//
//  Created by Ryan Olson on 4/4/14.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXExplorerToolbar.h"

@class IMLEXWindow;
@protocol IMLEXExplorerViewControllerDelegate;

/// A view controller that manages the IMLEX toolbar.
@interface IMLEXExplorerViewController : UIViewController

@property (nonatomic, weak) id <IMLEXExplorerViewControllerDelegate> delegate;
@property (nonatomic, readonly) BOOL wantsWindowToBecomeKey;

@property (nonatomic, readonly) IMLEXExplorerToolbar *explorerToolbar;

- (BOOL)shouldReceiveTouchAtWindowPoint:(CGPoint)pointInWindowCoordinates;

/// @brief Used to present (or dismiss) a modal view controller ("tool"), typically triggered by pressing a button in the toolbar.
///
/// If a tool is already presented, this method simply dismisses it and calls the completion block.
/// If no tool is presented, @code future() @endcode is presented and the completion block is called.
- (void)toggleToolWithViewControllerProvider:(UINavigationController *(^)(void))future completion:(void(^)(void))completion;

// Keyboard shortcut helpers

- (void)toggleSelectTool;
- (void)toggleMoveTool;
- (void)toggleViewsTool;
- (void)toggleMenuTool;

/// @return YES if the explorer used the key press to perform an action, NO otherwise
- (BOOL)handleDownArrowKeyPressed;
/// @return YES if the explorer used the key press to perform an action, NO otherwise
- (BOOL)handleUpArrowKeyPressed;
/// @return YES if the explorer used the key press to perform an action, NO otherwise
- (BOOL)handleRightArrowKeyPressed;
/// @return YES if the explorer used the key press to perform an action, NO otherwise
- (BOOL)handleLeftArrowKeyPressed;

@end

#pragma mark -
@protocol IMLEXExplorerViewControllerDelegate <NSObject>
- (void)explorerViewControllerDidFinish:(IMLEXExplorerViewController *)explorerViewController;
@end
