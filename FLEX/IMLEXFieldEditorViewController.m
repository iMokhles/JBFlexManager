//
//  IMLEXFieldEditorViewController.m
//  IMLEX
//
//  Created by Tanner on 11/22/18.
//  Copyright © 2018 Flipboard. All rights reserved.
//

#import "IMLEXFieldEditorViewController.h"
#import "IMLEXFieldEditorView.h"
#import "IMLEXArgumentInputViewFactory.h"
#import "IMLEXPropertyAttributes.h"
#import "IMLEXRuntimeUtility.h"
#import "IMLEXUtility.h"
#import "IMLEXColor.h"
#import "UIBarButtonItem+IMLEX.h"

@interface IMLEXFieldEditorViewController () <IMLEXArgumentInputViewDelegate>

@property (nonatomic) IMLEXProperty *property;
@property (nonatomic) IMLEXIvar *ivar;

@property (nonatomic, readonly) id currentValue;
@property (nonatomic, readonly) const IMLEXTypeEncoding *typeEncoding;
@property (nonatomic, readonly) NSString *fieldDescription;

@end

@implementation IMLEXFieldEditorViewController

#pragma mark - Initialization

+ (instancetype)target:(id)target property:(IMLEXProperty *)property {
    id value = [property getValue:target];
    if (![self canEditProperty:property onObject:target currentValue:value]) {
        return nil;
    }

    IMLEXFieldEditorViewController *editor = [self target:target];
    editor.title = [@"Property: " stringByAppendingString:property.name];
    editor.property = property;
    return editor;
}

+ (instancetype)target:(id)target ivar:(nonnull IMLEXIvar *)ivar {
    IMLEXFieldEditorViewController *editor = [self target:target];
    editor.title = [@"Ivar: " stringByAppendingString:ivar.name];
    editor.ivar = ivar;
    return editor;
}

#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = IMLEXColor.groupedBackgroundColor;

    // Create getter button
    _getterButton = [[UIBarButtonItem alloc]
        initWithTitle:@"Get"
        style:UIBarButtonItemStyleDone
        target:self
        action:@selector(getterButtonPressed:)
    ];
    self.toolbarItems = @[
        UIBarButtonItem.IMLEX_IMLEXibleSpace, self.getterButton, self.actionButton
    ];

    // Configure input view
    self.fieldEditorView.fieldDescription = self.fieldDescription;
    IMLEXArgumentInputView *inputView = [IMLEXArgumentInputViewFactory argumentInputViewForTypeEncoding:self.typeEncoding];
    inputView.inputValue = self.currentValue;
    inputView.delegate = self;
    self.fieldEditorView.argumentInputViews = @[inputView];

    // Don't show a "set" button for switches; we mutate when the switch is flipped
    if ([inputView isKindOfClass:[IMLEXArgumentInputSwitchView class]]) {
        self.actionButton.enabled = NO;
        self.actionButton.title = @"Flip the switch to call the setter";
        // Put getter button before setter button 
        self.toolbarItems = @[
            UIBarButtonItem.IMLEX_IMLEXibleSpace, self.actionButton, self.getterButton
        ];
    }
}

- (void)actionButtonPressed:(id)sender {
    [super actionButtonPressed:sender];

    if (self.property) {
        id userInputObject = self.firstInputView.inputValue;
        NSArray *arguments = userInputObject ? @[userInputObject] : nil;
        SEL setterSelector = self.property.likelySetter;
        NSError *error = nil;
        [IMLEXRuntimeUtility performSelector:setterSelector onObject:self.target withArguments:arguments error:&error];
        if (error) {
            [IMLEXAlert showAlert:@"Property Setter Failed" message:error.localizedDescription from:self];
            sender = nil; // Don't pop back
        }
    } else {
        // TODO: check mutability and use mutableCopy if necessary;
        // this currently could and would assign NSArray to NSMutableArray
        [self.ivar setValue:self.firstInputView.inputValue onObject:self.target];
    }

    // Go back after setting, but not for switches.
    if (sender) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        self.firstInputView.inputValue = self.currentValue;
    }
}

- (void)getterButtonPressed:(id)sender {
    [self.fieldEditorView endEditing:YES];

    [self exploreObjectOrPopViewController:self.currentValue];
}

- (void)argumentInputViewValueDidChange:(IMLEXArgumentInputView *)argumentInputView {
    if ([argumentInputView isKindOfClass:[IMLEXArgumentInputSwitchView class]]) {
        [self actionButtonPressed:nil];
    }
}

#pragma mark - Private

- (id)currentValue {
    if (self.property) {
        return [self.property getValue:self.target];
    } else {
        return [self.ivar getValue:self.target];
    }
}

- (const IMLEXTypeEncoding *)typeEncoding {
    if (self.property) {
        return self.property.attributes.typeEncoding.UTF8String;
    } else {
        return self.ivar.typeEncoding.UTF8String;
    }
}

- (NSString *)fieldDescription {
    if (self.property) {
        return self.property.fullDescription;
    } else {
        return self.ivar.description;
    }
}

+ (BOOL)canEditProperty:(IMLEXProperty *)property onObject:(id)object currentValue:(id)value {
    const IMLEXTypeEncoding *typeEncoding = property.attributes.typeEncoding.UTF8String;
    BOOL canEditType = [IMLEXArgumentInputViewFactory canEditFieldWithTypeEncoding:typeEncoding currentValue:value];
    return canEditType && [object respondsToSelector:property.likelySetter];
}

+ (BOOL)canEditIvar:(Ivar)ivar currentValue:(id)value {
    return [IMLEXArgumentInputViewFactory canEditFieldWithTypeEncoding:ivar_getTypeEncoding(ivar) currentValue:value];
}

@end
