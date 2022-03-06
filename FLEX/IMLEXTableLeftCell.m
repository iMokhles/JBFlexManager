//
//  IMLEXTableLeftCell.m
//  IMLEX
//
//  Created by Peng Tao on 15/11/24.
//  Copyright © 2015年 f. All rights reserved.
//

#import "IMLEXTableLeftCell.h"

@implementation IMLEXTableLeftCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"IMLEXTableLeftCell";
    IMLEXTableLeftCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[IMLEXTableLeftCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UILabel *textLabel               = [UILabel new];
        textLabel.textAlignment          = NSTextAlignmentCenter;
        textLabel.font                   = [UIFont systemFontOfSize:13.0];
        [cell.contentView addSubview:textLabel];
        cell.titlelabel = textLabel;
    }
    
    return cell;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titlelabel.frame = self.contentView.frame;
}
@end
