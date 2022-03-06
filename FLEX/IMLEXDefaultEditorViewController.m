//
//  IMLEXDefaultEditorViewController.m
//  Flipboard
//
//  Created by Ryan Olson on 5/23/14.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXDefaultEditorViewController.h"
#import "IMLEXFieldEditorView.h"
#import "IMLEXRuntimeUtility.h"
#import "IMLEXArgumentInputView.h"
#import "IMLEXArgumentInputViewFactory.h"

@interface IMLEXDefaultEditorViewController ()

@property (nonatomic, readonly) NSUserDefaults *defaults;
@property (nonatomic) NSString *key;

@end

@implementation IMLEXDefaultEditorViewController

- (id)initWithDefaults:(NSUserDefaults *)defaults key:(NSString *)key {
    self = [super initWithTarget:defaults];
    if (self) {
        self.key = key;
        self.title = @"Edit Default";
    }
    return self;
}

- (NSUserDefaults *)defaults {
    return [self.target isKindOfClass:[NSUserDefaults class]] ? self.target : nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fieldEditorView.fieldDescription = self.key;

    id currentValue = [self.defaults objectForKey:self.key];
    IMLEXArgumentInputView *inputView = [IMLEXArgumentInputViewFactory
        argumentInputViewForTypeEncoding:IMLEXEncodeObject(currentValue)
        currentValue:currentValue
    ];
    inputView.backgroundColor = self.view.backgroundColor;
    inputView.inputValue = currentValue;
    self.fieldEditorView.argumentInputViews = @[inputView];
}

- (void)actionButtonPressed:(id)sender {
    [super actionButtonPressed:sender];
    
    id value = self.firstInputView.inputValue;
    if (value) {
        [self.defaults setObject:value forKey:self.key];
    } else {
        [self.defaults removeObjectForKey:self.key];
    }
    [self.defaults synchronize];

    self.firstInputView.inputValue = [self.defaults objectForKey:self.key];
}

- (void)getterButtonPressed:(id)sender {
    [super getterButtonPressed:sender];
    id returnedObject = [self.defaults objectForKey:self.key];
    [self exploreObjectOrPopViewController:returnedObject];
}

+ (BOOL)canEditDefaultWithValue:(id)currentValue {
    return [IMLEXArgumentInputViewFactory
        canEditFieldWithTypeEncoding:IMLEXEncodeObject(currentValue)
        currentValue:currentValue
    ];
}

@end
