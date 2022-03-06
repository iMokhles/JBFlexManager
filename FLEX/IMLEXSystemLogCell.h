//
//  IMLEXSystemLogCell.h
//  IMLEX
//
//  Created by Ryan Olson on 1/25/15.
//  Copyright (c) 2015 f. All rights reserved.
//

#import "IMLEXTableViewCell.h"

@class IMLEXSystemLogMessage;

extern NSString *const kIMLEXSystemLogCellIdentifier;

@interface IMLEXSystemLogCell : IMLEXTableViewCell

@property (nonatomic) IMLEXSystemLogMessage *logMessage;
@property (nonatomic, copy) NSString *highlightedText;

+ (NSString *)displayedTextForLogMessage:(IMLEXSystemLogMessage *)logMessage;
+ (CGFloat)preferredHeightForLogMessage:(IMLEXSystemLogMessage *)logMessage inWidth:(CGFloat)width;

@end
