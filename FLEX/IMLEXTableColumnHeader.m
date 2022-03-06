//
//  IMLEXTableContentHeaderCell.m
//  IMLEX
//
//  Created by Peng Tao on 15/11/26.
//  Copyright © 2015年 f. All rights reserved.
//

#import "IMLEXTableColumnHeader.h"
#import "IMLEXColor.h"
#import "UIFont+IMLEX.h"
#import "IMLEXUtility.h"

@interface IMLEXTableColumnHeader ()
@property (nonatomic, readonly) UILabel *arrowLabel;
@property (nonatomic, readonly) UIView *lineView;
@end

@implementation IMLEXTableColumnHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = IMLEXColor.secondaryBackgroundColor;
        
        _titleLabel = [UILabel new];
        _titleLabel.font = UIFont.IMLEX_defaultTableCellFont;
        [self addSubview:_titleLabel];
        
        _arrowLabel = [UILabel new];
        _arrowLabel.font = UIFont.IMLEX_defaultTableCellFont;
        [self addSubview:_arrowLabel];
        
        _lineView = [UIView new];
        _lineView.backgroundColor = IMLEXColor.hairlineColor;
        [self addSubview:_lineView];
        
    }
    return self;
}

- (void)setSortType:(IMLEXTableColumnHeaderSortType)type {
    _sortType = type;
    
    switch (type) {
        case IMLEXTableColumnHeaderSortTypeNone:
            _arrowLabel.text = @"";
            break;
        case IMLEXTableColumnHeaderSortTypeAsc:
            _arrowLabel.text = @"⬆️";
            break;
        case IMLEXTableColumnHeaderSortTypeDesc:
            _arrowLabel.text = @"⬇️";
            break;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.frame.size;
    
    self.titleLabel.frame = CGRectMake(5, 0, size.width - 25, size.height);
    self.arrowLabel.frame = CGRectMake(size.width - 20, 0, 20, size.height);
    self.lineView.frame = CGRectMake(size.width - 1, 2, IMLEXPointsToPixels(1), size.height - 4);
}

@end
