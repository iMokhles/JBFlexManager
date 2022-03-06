//
//  IMLEXFieldEditorViewController.h
//  IMLEX
//
//  Created by Tanner on 11/22/18.
//  Copyright © 2018 Flipboard. All rights reserved.
//

#import "IMLEXVariableEditorViewController.h"
#import "IMLEXProperty.h"
#import "IMLEXIvar.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMLEXFieldEditorViewController : IMLEXVariableEditorViewController

/// @return nil if the property is readonly or if the type is unsupported
+ (nullable instancetype)target:(id)target property:(IMLEXProperty *)property;
/// @return nil if the ivar type is unsupported
+ (nullable instancetype)target:(id)target ivar:(IMLEXIvar *)ivar;

/// Subclasses can change the button title via the \c title property
@property (nonatomic, readonly) UIBarButtonItem *getterButton;

- (void)getterButtonPressed:(id)sender;

@end

NS_ASSUME_NONNULL_END
