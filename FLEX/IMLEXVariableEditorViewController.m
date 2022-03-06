//
//  IMLEXVariableEditorViewController.m
//  Flipboard
//
//  Created by Ryan Olson on 5/16/14.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXColor.h"
#import "IMLEXVariableEditorViewController.h"
#import "IMLEXFieldEditorView.h"
#import "IMLEXRuntimeUtility.h"
#import "IMLEXUtility.h"
#import "IMLEXObjectExplorerFactory.h"
#import "IMLEXArgumentInputView.h"
#import "IMLEXArgumentInputViewFactory.h"
#import "IMLEXObjectExplorerViewController.h"
#import "UIBarButtonItem+IMLEX.h"

@interface IMLEXVariableEditorViewController () <UIScrollViewDelegate>
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) id target;
@end

@implementation IMLEXVariableEditorViewController

#pragma mark - Initialization

+ (instancetype)target:(id)target {
    return [[self alloc] initWithTarget:target];
}

- (id)initWithTarget:(id)target {
    self = [super init];
    if (self) {
        self.target = target;
        [NSNotificationCenter.defaultCenter
            addObserver:self selector:@selector(keyboardDidShow:)
            name:UIKeyboardDidShowNotification object:nil
        ];
        [NSNotificationCenter.defaultCenter
            addObserver:self selector:@selector(keyboardWillHide:)
            name:UIKeyboardWillHideNotification object:nil
        ];
    }

    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - UIViewController methods

- (void)keyboardDidShow:(NSNotification *)notification {
    CGRect keyboardRectInWindow = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize keyboardSize = [self.view convertRect:keyboardRectInWindow fromView:nil].size;
    UIEdgeInsets scrollInsets = self.scrollView.contentInset;
    scrollInsets.bottom = keyboardSize.height;
    self.scrollView.contentInset = scrollInsets;
    self.scrollView.scrollIndicatorInsets = scrollInsets;

    // Find the active input view and scroll to make sure it's visible.
    for (IMLEXArgumentInputView *argumentInputView in self.fieldEditorView.argumentInputViews) {
        if (argumentInputView.inputViewIsFirstResponder) {
            CGRect scrollToVisibleRect = [self.scrollView convertRect:argumentInputView.bounds fromView:argumentInputView];
            [self.scrollView scrollRectToVisible:scrollToVisibleRect animated:YES];
            break;
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets scrollInsets = self.scrollView.contentInset;
    scrollInsets.bottom = 0.0;
    self.scrollView.contentInset = scrollInsets;
    self.scrollView.scrollIndicatorInsets = scrollInsets;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = IMLEXColor.scrollViewBackgroundColor;

    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = self.view.backgroundColor;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];

    _fieldEditorView = [IMLEXFieldEditorView new];
    self.fieldEditorView.targetDescription = [NSString stringWithFormat:@"%@ %p", [self.target class], self.target];
    [self.scrollView addSubview:self.fieldEditorView];

    _actionButton = [[UIBarButtonItem alloc]
        initWithTitle:@"Set"
        style:UIBarButtonItemStyleDone
        target:self
        action:@selector(actionButtonPressed:)
    ];

    self.navigationController.toolbarHidden = NO;
    self.toolbarItems = @[UIBarButtonItem.IMLEX_IMLEXibleSpace, self.actionButton];
}

- (void)viewWillLayoutSubviews {
    CGSize constrainSize = CGSizeMake(self.scrollView.bounds.size.width, CGFLOAT_MAX);
    CGSize fieldEditorSize = [self.fieldEditorView sizeThatFits:constrainSize];
    self.fieldEditorView.frame = CGRectMake(0, 0, fieldEditorSize.width, fieldEditorSize.height);
    self.scrollView.contentSize = fieldEditorSize;
}

#pragma mark - Public

- (IMLEXArgumentInputView *)firstInputView {
    return [self.fieldEditorView argumentInputViews].firstObject;
}

- (void)actionButtonPressed:(id)sender {
    // Subclasses can override
    [self.fieldEditorView endEditing:YES];
}

- (void)exploreObjectOrPopViewController:(id)objectOrNil {
    if (objectOrNil) {
        // For non-nil (or void) return types, push an explorer view controller to display the object
        IMLEXObjectExplorerViewController *explorerViewController = [IMLEXObjectExplorerFactory explorerViewControllerForObject:objectOrNil];
        [self.navigationController pushViewController:explorerViewController animated:YES];
    } else {
        // If we didn't get a returned object but the method call succeeded,
        // pop this view controller off the stack to indicate that the call went through.
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
