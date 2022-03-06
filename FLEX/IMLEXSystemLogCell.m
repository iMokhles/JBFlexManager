//
//  IMLEXSystemLogCell.m
//  IMLEX
//
//  Created by Ryan Olson on 1/25/15.
//  Copyright (c) 2015 f. All rights reserved.
//

#import "IMLEXSystemLogCell.h"
#import "IMLEXSystemLogMessage.h"
#import "UIFont+IMLEX.h"

NSString *const kIMLEXSystemLogCellIdentifier = @"IMLEXSystemLogCellIdentifier";

@interface IMLEXSystemLogCell ()

@property (nonatomic) UILabel *logMessageLabel;
@property (nonatomic) NSAttributedString *logMessageAttributedText;

@end

@implementation IMLEXSystemLogCell

- (void)postInit {
    [super postInit];
    
    self.logMessageLabel = [UILabel new];
    self.logMessageLabel.numberOfLines = 0;
    self.separatorInset = UIEdgeInsetsZero;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.logMessageLabel];
}

- (void)setLogMessage:(IMLEXSystemLogMessage *)logMessage {
    if (![_logMessage isEqual:logMessage]) {
        _logMessage = logMessage;
        self.logMessageAttributedText = nil;
        [self setNeedsLayout];
    }
}

- (void)setHighlightedText:(NSString *)highlightedText {
    if (![_highlightedText isEqual:highlightedText]) {
        _highlightedText = highlightedText;
        self.logMessageAttributedText = nil;
        [self setNeedsLayout];
    }
}

- (NSAttributedString *)logMessageAttributedText {
    if (!_logMessageAttributedText) {
        _logMessageAttributedText = [[self class] attributedTextForLogMessage:self.logMessage highlightedText:self.highlightedText];
    }
    return _logMessageAttributedText;
}

static const UIEdgeInsets kIMLEXLogMessageCellInsets = {10.0, 10.0, 10.0, 10.0};

- (void)layoutSubviews {
    [super layoutSubviews];

    self.logMessageLabel.attributedText = self.logMessageAttributedText;
    self.logMessageLabel.frame = UIEdgeInsetsInsetRect(self.contentView.bounds, kIMLEXLogMessageCellInsets);
}


#pragma mark - Stateless helpers

+ (NSAttributedString *)attributedTextForLogMessage:(IMLEXSystemLogMessage *)logMessage highlightedText:(NSString *)highlightedText {
    NSString *text = [self displayedTextForLogMessage:logMessage];
    NSDictionary<NSString *, id> *attributes = @{ NSFontAttributeName : UIFont.IMLEX_codeFont };
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];

    if (highlightedText.length > 0) {
        NSMutableAttributedString *mutableAttributedText = attributedText.mutableCopy;
        NSMutableDictionary<NSString *, id> *highlightAttributes = attributes.mutableCopy;
        highlightAttributes[NSBackgroundColorAttributeName] = UIColor.yellowColor;
        
        NSRange remainingSearchRange = NSMakeRange(0, text.length);
        while (remainingSearchRange.location < text.length) {
            remainingSearchRange.length = text.length - remainingSearchRange.location;
            NSRange foundRange = [text rangeOfString:highlightedText options:NSCaseInsensitiveSearch range:remainingSearchRange];
            if (foundRange.location != NSNotFound) {
                remainingSearchRange.location = foundRange.location + foundRange.length;
                [mutableAttributedText setAttributes:highlightAttributes range:foundRange];
            } else {
                break;
            }
        }
        attributedText = mutableAttributedText;
    }

    return attributedText;
}

+ (NSString *)displayedTextForLogMessage:(IMLEXSystemLogMessage *)logMessage {
    return [NSString stringWithFormat:@"%@: %@", [self logTimeStringFromDate:logMessage.date], logMessage.messageText];
}

+ (CGFloat)preferredHeightForLogMessage:(IMLEXSystemLogMessage *)logMessage inWidth:(CGFloat)width {
    UIEdgeInsets insets = kIMLEXLogMessageCellInsets;
    CGFloat availableWidth = width - insets.left - insets.right;
    NSAttributedString *attributedLogText = [self attributedTextForLogMessage:logMessage highlightedText:nil];
    CGSize labelSize = [attributedLogText boundingRectWithSize:CGSizeMake(availableWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size;
    return labelSize.height + insets.top + insets.bottom;
}

+ (NSString *)logTimeStringFromDate:(NSDate *)date {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    });

    return [formatter stringFromDate:date];
}

@end
