//
//  PTTableContentViewController.m
//  PTDatabaseReader
//
//  Created by Peng Tao on 15/11/23.
//  Copyright © 2015年 Peng Tao. All rights reserved.
//

#import "IMLEXTableContentViewController.h"
#import "IMLEXMultiColumnTableView.h"
#import "IMLEXWebViewController.h"
#import "IMLEXUtility.h"

@interface IMLEXTableContentViewController () <
    IMLEXMultiColumnTableViewDataSource, IMLEXMultiColumnTableViewDelegate
>
@property (nonatomic, readonly) NSArray<NSString *> *columns;
@property (nonatomic, copy) NSArray<NSArray *> *rows;

@property (nonatomic) IMLEXMultiColumnTableView *multiColumnView;
@end

@implementation IMLEXTableContentViewController

+ (instancetype)columns:(NSArray<NSString *> *)columnNames
                   rows:(NSArray<NSArray<NSString *> *> *)rowData {
    IMLEXTableContentViewController *controller = [self new];
    controller->_columns = columnNames;
    controller->_rows = rowData;
    return controller;
}

- (void)loadView {
    [super loadView];
    
    [self.view addSubview:self.multiColumnView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.multiColumnView reloadData];
}

- (IMLEXMultiColumnTableView *)multiColumnView {
    if (!_multiColumnView) {
        _multiColumnView = [[IMLEXMultiColumnTableView alloc]
            initWithFrame:IMLEXRectSetSize(CGRectZero, self.view.frame.size)
        ];
        
        _multiColumnView.dataSource = self;
        _multiColumnView.delegate   = self;
    }
    
    return _multiColumnView;
}

#pragma mark MultiColumnTableView DataSource

- (NSInteger)numberOfColumnsInTableView:(IMLEXMultiColumnTableView *)tableView {
    return self.columns.count;
}

- (NSInteger)numberOfRowsInTableView:(IMLEXMultiColumnTableView *)tableView {
    return self.rows.count;
}

- (NSString *)columnTitle:(NSInteger)column {
    return self.columns[column];
}

- (NSString *)rowTitle:(NSInteger)row {
    return @(row).stringValue;
}

- (NSArray *)contentForRow:(NSInteger)row {
    return self.rows[row];
}

- (CGFloat)multiColumnTableView:(IMLEXMultiColumnTableView *)tableView
      heightForContentCellInRow:(NSInteger)row {
    return 40;
}

- (CGFloat)multiColumnTableView:(IMLEXMultiColumnTableView *)tableView
    widthForContentCellInColumn:(NSInteger)column {
    return 120;
}

- (CGFloat)heightForTopHeaderInTableView:(IMLEXMultiColumnTableView *)tableView {
    return 40;
}

- (CGFloat)widthForLeftHeaderInTableView:(IMLEXMultiColumnTableView *)tableView {
    NSString *str = [NSString stringWithFormat:@"%lu",(unsigned long)self.rows.count];
    NSDictionary *attrs = @{ NSFontAttributeName : [UIFont systemFontOfSize:17.0] };
    CGSize size = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 14)
        options:NSStringDrawingUsesLineFragmentOrigin
        attributes:attrs context:nil
    ].size;
    
    return size.width + 20;
}


#pragma mark MultiColumnTableView Delegate

- (void)multiColumnTableView:(IMLEXMultiColumnTableView *)tableView didSelectRow:(NSInteger)row {
    NSArray<NSString *> *fields = [self.rows[row] IMLEX_mapped:^id(NSString *field, NSUInteger idx) {
        return [NSString stringWithFormat:@"%@:\n%@", self.columns[idx], field];
    }];
    
    [IMLEXAlert makeAlert:^(IMLEXAlert *make) {
        make.title([@"Row " stringByAppendingString:@(row).stringValue]);
        make.message([fields componentsJoinedByString:@"\n\n"]);
        make.button(@"Dismiss").cancelStyle();
    } showFrom:self];
}

- (void)multiColumnTableView:(IMLEXMultiColumnTableView *)tableView
    didSelectHeaderForColumn:(NSInteger)column
                    sortType:(IMLEXTableColumnHeaderSortType)sortType {
    
    NSArray<NSArray *> *sortContentData = [self.rows
        sortedArrayUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
            id a = obj1[column], b = obj2[column];
            if (a == NSNull.null) {
                return NSOrderedAscending;
            }
            if (b == NSNull.null) {
                return NSOrderedDescending;
            }
            
            if ([a respondsToSelector:@selector(compare:)] && [b respondsToSelector:@selector(compare:)]) {
                return [a compare:b];
            }
            
            return NSOrderedSame;
        }
    ];
    
    if (sortType == IMLEXTableColumnHeaderSortTypeDesc) {
        sortContentData = sortContentData.reverseObjectEnumerator.allObjects.copy;
    }
    
    self.rows = sortContentData;
    [self.multiColumnView reloadData];
}

#pragma mark -
#pragma mark About Transition

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
              withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        if (newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
            self.multiColumnView.frame = CGRectMake(0, 32, self.view.frame.size.width, self.view.frame.size.height - 32);
        }
        else {
            self.multiColumnView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
        }
        
        [self.view setNeedsLayout];
    } completion:nil];
}

@end
