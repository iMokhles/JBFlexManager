//
//  PTMultiColumnTableView.h
//  PTMultiColumnTableViewDemo
//
//  Created by Peng Tao on 15/11/16.
//  Copyright © 2015年 Peng Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMLEXTableColumnHeader.h"

@class IMLEXMultiColumnTableView;

@protocol IMLEXMultiColumnTableViewDelegate <NSObject>

@required
- (void)multiColumnTableView:(IMLEXMultiColumnTableView *)tableView didSelectRow:(NSInteger)row;
- (void)multiColumnTableView:(IMLEXMultiColumnTableView *)tableView didSelectHeaderForColumn:(NSInteger)column sortType:(IMLEXTableColumnHeaderSortType)sortType;

@end

@protocol IMLEXMultiColumnTableViewDataSource <NSObject>

@required

- (NSInteger)numberOfColumnsInTableView:(IMLEXMultiColumnTableView *)tableView;
- (NSInteger)numberOfRowsInTableView:(IMLEXMultiColumnTableView *)tableView;
- (NSString *)columnTitle:(NSInteger)column;
- (NSString *)rowTitle:(NSInteger)row;
- (NSArray<NSString *> *)contentForRow:(NSInteger)row;

- (CGFloat)multiColumnTableView:(IMLEXMultiColumnTableView *)tableView widthForContentCellInColumn:(NSInteger)column;
- (CGFloat)multiColumnTableView:(IMLEXMultiColumnTableView *)tableView heightForContentCellInRow:(NSInteger)row;
- (CGFloat)heightForTopHeaderInTableView:(IMLEXMultiColumnTableView *)tableView;
- (CGFloat)widthForLeftHeaderInTableView:(IMLEXMultiColumnTableView *)tableView;

@end


@interface IMLEXMultiColumnTableView : UIView

@property (nonatomic, weak) id<IMLEXMultiColumnTableViewDataSource> dataSource;
@property (nonatomic, weak) id<IMLEXMultiColumnTableViewDelegate> delegate;

- (void)reloadData;

@end
