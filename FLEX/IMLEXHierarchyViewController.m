//
//  IMLEXHierarchyViewController.m
//  IMLEX
//
//  Created by Tanner Bennett on 1/9/20.
//  Copyright © 2020 Flipboard. All rights reserved.
//

#import "IMLEXHierarchyViewController.h"
#import "IMLEXHierarchyTableViewController.h"
#import "FHSViewController.h"
#import "IMLEXUtility.h"
#import "IMLEXTabList.h"
#import "IMLEXResources.h"
#import "UIBarButtonItem+IMLEX.h"

typedef NS_ENUM(NSUInteger, IMLEXHierarchyViewMode) {
    IMLEXHierarchyViewModeTree = 1,
    IMLEXHierarchyViewMode3DSnapshot
};

@interface IMLEXHierarchyViewController ()
@property (nonatomic, readonly, weak) id<IMLEXHierarchyDelegate> hierarchyDelegate;
@property (nonatomic, readonly) FHSViewController *snapshotViewController;
@property (nonatomic, readonly) IMLEXHierarchyTableViewController *treeViewController;

@property (nonatomic) IMLEXHierarchyViewMode mode;

@property (nonatomic, readonly) UIView *selectedView;
@end

@implementation IMLEXHierarchyViewController

#pragma mark - Initialization

+ (instancetype)delegate:(id<IMLEXHierarchyDelegate>)delegate {
    return [self delegate:delegate viewsAtTap:nil selectedView:nil];
}

+ (instancetype)delegate:(id<IMLEXHierarchyDelegate>)delegate
              viewsAtTap:(NSArray<UIView *> *)viewsAtTap
            selectedView:(UIView *)selectedView {
    return [[self alloc] initWithDelegate:delegate viewsAtTap:viewsAtTap selectedView:selectedView];
}

- (id)initWithDelegate:(id)delegate viewsAtTap:(NSArray<UIView *> *)viewsAtTap selectedView:(UIView *)view {
    self = [super init];
    if (self) {
        NSArray<UIWindow *> *allWindows = IMLEXUtility.allWindows;
        _hierarchyDelegate = delegate;
        _treeViewController = [IMLEXHierarchyTableViewController
            windows:allWindows viewsAtTap:viewsAtTap selectedView:view
        ];

        if (viewsAtTap) {
            _snapshotViewController = [FHSViewController snapshotViewsAtTap:viewsAtTap selectedView:view];
        } else {
            _snapshotViewController = [FHSViewController snapshotWindows:allWindows];
        }

        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }

    return self;
}


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // 3D toggle button
    self.treeViewController.navigationItem.leftBarButtonItem = [UIBarButtonItem
        itemWithImage:IMLEXResources.toggle3DIcon target:self action:@selector(toggleHierarchyMode)
    ];

    // Dismiss when tree view row is selected
    __weak id<IMLEXHierarchyDelegate> delegate = self.hierarchyDelegate;
    self.treeViewController.didSelectRowAction = ^(UIView *selectedView) {
        [delegate viewHierarchyDidDismiss:selectedView];
    };

    // Start of in tree view
    _mode = IMLEXHierarchyViewModeTree;
    [self pushViewController:self.treeViewController animated:NO];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // Done button: manually added here because the hierarhcy screens need to actually pass
    // data back to the explorer view controller so that it can highlight selected views
    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed)
    ];

    [super pushViewController:viewController animated:animated];
}


#pragma mark - Private

- (void)donePressed {
    // We need to manually close ourselves here because
    // IMLEXNavigationController doesn't ever close tabs itself 
    [IMLEXTabList.sharedList closeTab:self];
    [self.hierarchyDelegate viewHierarchyDidDismiss:self.selectedView];
}

- (void)toggleHierarchyMode {
    switch (self.mode) {
        case IMLEXHierarchyViewModeTree:
            self.mode = IMLEXHierarchyViewMode3DSnapshot;
            break;
        case IMLEXHierarchyViewMode3DSnapshot:
            self.mode = IMLEXHierarchyViewModeTree;
            break;
    }
}

- (void)setMode:(IMLEXHierarchyViewMode)mode {
    if (mode != _mode) {
        // The tree view controller is our top stack view controller, and
        // changing the mode simply pushes the snapshot view. In the future,
        // I would like to have the 3D toggle button transparently switch
        // between two views instead of pushing a new view controller.
        // This way the views should share the search controller somehow.
        switch (mode) {
            case IMLEXHierarchyViewModeTree:
                [self popViewControllerAnimated:NO];
                self.toolbarHidden = YES;
                self.treeViewController.selectedView = self.selectedView;
                break;
            case IMLEXHierarchyViewMode3DSnapshot:
                [self pushViewController:self.snapshotViewController animated:NO];
                self.toolbarHidden = NO;
                self.snapshotViewController.selectedView = self.selectedView;
                break;
        }

        // Change this last so that self.selectedView works right above
        _mode = mode;
    }
}

- (UIView *)selectedView {
    switch (self.mode) {
        case IMLEXHierarchyViewModeTree:
            return self.treeViewController.selectedView;
        case IMLEXHierarchyViewMode3DSnapshot:
            return self.snapshotViewController.selectedView;
    }
}

@end
