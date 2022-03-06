//
//  IMLEXArgumentInputTextView.h
//  IMLEXInjected
//
//  Created by Ryan Olson on 6/15/14.
//
//

#import "IMLEXArgumentInputView.h"

@interface IMLEXArgumentInputTextView : IMLEXArgumentInputView <UITextViewDelegate>

// For subclass eyes only

@property (nonatomic, readonly) UITextView *inputTextView;
@property (nonatomic) NSString *inputPlaceholderText;

@end
