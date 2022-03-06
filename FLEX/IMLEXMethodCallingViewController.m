//
//  IMLEXMethodCallingViewController.m
//  Flipboard
//
//  Created by Ryan Olson on 5/23/14.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXMethodCallingViewController.h"
#import "IMLEXRuntimeUtility.h"
#import "IMLEXFieldEditorView.h"
#import "IMLEXObjectExplorerFactory.h"
#import "IMLEXObjectExplorerViewController.h"
#import "IMLEXArgumentInputView.h"
#import "IMLEXArgumentInputViewFactory.h"
#import "IMLEXUtility.h"

@interface IMLEXMethodCallingViewController ()
@property (nonatomic) IMLEXMethod *method;
@end

@implementation IMLEXMethodCallingViewController

+ (instancetype)target:(id)target method:(IMLEXMethod *)method {
    return [[self alloc] initWithTarget:target method:method];
}

- (id)initWithTarget:(id)target method:(IMLEXMethod *)method {
    NSParameterAssert(method.isInstanceMethod == !object_isClass(target));

    self = [super initWithTarget:target];
    if (self) {
        self.method = method;
        self.title = method.isInstanceMethod ? @"Method: " : @"Class Method: ";
        self.title = [self.title stringByAppendingString:method.selectorString];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.actionButton.title = @"Call";

    // Configure field editor view
    self.fieldEditorView.argumentInputViews = [self argumentInputViews];
    self.fieldEditorView.fieldDescription = [NSString stringWithFormat:
        @"Signature:\n%@\n\nReturn Type:\n%s",
        self.method.description, (char *)self.method.returnType
    ];
}

- (NSArray<IMLEXArgumentInputView *> *)argumentInputViews {
    Method method = self.method.objc_method;
    NSArray *methodComponents = [IMLEXRuntimeUtility prettyArgumentComponentsForMethod:method];
    NSMutableArray<IMLEXArgumentInputView *> *argumentInputViews = [NSMutableArray new];
    unsigned int argumentIndex = kIMLEXNumberOfImplicitArgs;

    for (NSString *methodComponent in methodComponents) {
        char *argumentTypeEncoding = method_copyArgumentType(method, argumentIndex);
        IMLEXArgumentInputView *inputView = [IMLEXArgumentInputViewFactory argumentInputViewForTypeEncoding:argumentTypeEncoding];
        free(argumentTypeEncoding);

        inputView.backgroundColor = self.view.backgroundColor;
        inputView.title = methodComponent;
        [argumentInputViews addObject:inputView];
        argumentIndex++;
    }

    return argumentInputViews;
}

- (void)actionButtonPressed:(id)sender {
    [super actionButtonPressed:sender];

    // Gather arguments
    NSMutableArray *arguments = [NSMutableArray new];
    for (IMLEXArgumentInputView *inputView in self.fieldEditorView.argumentInputViews) {
        // Use NSNull as a nil placeholder; it will be interpreted as nil
        [arguments addObject:inputView.inputValue ?: NSNull.null];
    }

    // Call method
    NSError *error = nil;
    id returnValue = [IMLEXRuntimeUtility
        performSelector:self.method.selector
        onObject:self.target
        withArguments:arguments
        error:&error
    ];

    // Display return value or error
    if (error) {
        [IMLEXAlert showAlert:@"Method Call Failed" message:error.localizedDescription from:self];
    } else if (returnValue) {
        // For non-nil (or void) return types, push an explorer view controller to display the returned object
        returnValue = [IMLEXRuntimeUtility potentiallyUnwrapBoxedPointer:returnValue type:self.method.returnType];
        IMLEXObjectExplorerViewController *explorer = [IMLEXObjectExplorerFactory explorerViewControllerForObject:returnValue];
        [self.navigationController pushViewController:explorer animated:YES];
    } else {
        [self exploreObjectOrPopViewController:returnValue];
    }
}

@end
