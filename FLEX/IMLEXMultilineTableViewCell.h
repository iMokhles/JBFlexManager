//
//  IMLEXMultilineTableViewCell.h
//  IMLEX
//
//  Created by Ryan Olson on 2/13/15.
//  Copyright (c) 2015 f. All rights reserved.
//

#import "IMLEXTableViewCell.h"

/// A cell with both labels set to be multi-line capable.
@interface IMLEXMultilineTableViewCell : IMLEXTableViewCell

+ (CGFloat)preferredHeightWithAttributedText:(NSAttributedString *)attributedText
                                    maxWidth:(CGFloat)contentViewWidth
                                       style:(UITableViewStyle)style
                              showsAccessory:(BOOL)showsAccessory;

@end

/// A \c IMLEXMultilineTableViewCell initialized with \c UITableViewCellStyleSubtitle
@interface IMLEXMultilineDetailTableViewCell : IMLEXMultilineTableViewCell

@end
