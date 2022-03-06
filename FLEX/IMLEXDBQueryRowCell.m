//
//  IMLEXDBQueryRowCell.m
//  IMLEX
//
//  Created by Peng Tao on 15/11/24.
//  Copyright © 2015年 f. All rights reserved.
//

#import "IMLEXDBQueryRowCell.h"
#import "IMLEXMultiColumnTableView.h"
#import "NSArray+Functional.h"
#import "UIFont+IMLEX.h"
#import "IMLEXColor.h"

NSString * const kIMLEXDBQueryRowCellReuse = @"kIMLEXDBQueryRowCellReuse";

@interface IMLEXDBQueryRowCell ()
@property (nonatomic) NSInteger columnCount;
@property (nonatomic) NSArray<UILabel *> *labels;
@end

@implementation IMLEXDBQueryRowCell

- (void)setData:(NSArray *)data {
    _data = data;
    self.columnCount = data.count;
    
    [self.labels IMLEX_forEach:^(UILabel *label, NSUInteger idx) {
        id content = self.data[idx];
        
        if ([content isKindOfClass:[NSString class]]) {
            label.text = content;
        } else if (content == NSNull.null) {
            label.text = @"<null>";
            label.textColor = IMLEXColor.deemphasizedTextColor;
        } else {
            label.text = [content description];
        }
    }];
}

- (void)setColumnCount:(NSInteger)columnCount {
    if (columnCount != _columnCount) {
        _columnCount = columnCount;
        
        // Remove existing labels
        for (UILabel *l in self.labels) {
            [l removeFromSuperview];
        }
        
        // Create new labels
        self.labels = [NSArray IMLEX_forEachUpTo:columnCount map:^id(NSUInteger i) {
            UILabel *label = [UILabel new];
            label.font = UIFont.IMLEX_defaultTableCellFont;
            label.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:label];
            
            return label;
        }];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width  = self.contentView.frame.size.width / self.labels.count;
    CGFloat height = self.contentView.frame.size.height;
    
    [self.labels IMLEX_forEach:^(UILabel *label, NSUInteger i) {
        label.frame = CGRectMake(width * i + 5, 0, (width - 10), height);
    }];
}

@end
