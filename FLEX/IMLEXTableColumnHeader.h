//
//  IMLEXTableContentHeaderCell.h
//  IMLEX
//
//  Created by Peng Tao on 15/11/26.
//  Copyright © 2015年 f. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, IMLEXTableColumnHeaderSortType) {
    IMLEXTableColumnHeaderSortTypeNone = 0,
    IMLEXTableColumnHeaderSortTypeAsc,
    IMLEXTableColumnHeaderSortTypeDesc,
};

NS_INLINE IMLEXTableColumnHeaderSortType IMLEXNextTableColumnHeaderSortType(
    IMLEXTableColumnHeaderSortType current) {
    switch (current) {
        case IMLEXTableColumnHeaderSortTypeAsc:
            return IMLEXTableColumnHeaderSortTypeDesc;
        case IMLEXTableColumnHeaderSortTypeNone:
        case IMLEXTableColumnHeaderSortTypeDesc:
            return IMLEXTableColumnHeaderSortTypeAsc;
    }
    
    return IMLEXTableColumnHeaderSortTypeNone;
}

@interface IMLEXTableColumnHeader : UIView

@property (nonatomic) NSInteger index;
@property (nonatomic, readonly) UILabel *titleLabel;

@property (nonatomic) IMLEXTableColumnHeaderSortType sortType;

@end

