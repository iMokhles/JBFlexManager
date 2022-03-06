//
//  IMLEXTableView.m
//  IMLEX
//
//  Created by Tanner on 4/17/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXTableView.h"
#import "IMLEXUtility.h"
#import "IMLEXSubtitleTableViewCell.h"
#import "IMLEXMultilineTableViewCell.h"
#import "IMLEXKeyValueTableViewCell.h"
#import "IMLEXCodeFontCell.h"

IMLEXTableViewCellReuseIdentifier const kIMLEXDefaultCell = @"kIMLEXDefaultCell";
IMLEXTableViewCellReuseIdentifier const kIMLEXDetailCell = @"kIMLEXDetailCell";
IMLEXTableViewCellReuseIdentifier const kIMLEXMultilineCell = @"kIMLEXMultilineCell";
IMLEXTableViewCellReuseIdentifier const kIMLEXMultilineDetailCell = @"kIMLEXMultilineDetailCell";
IMLEXTableViewCellReuseIdentifier const kIMLEXKeyValueCell = @"kIMLEXKeyValueCell";
IMLEXTableViewCellReuseIdentifier const kIMLEXCodeFontCell = @"kIMLEXCodeFontCell";

#pragma mark Private

@interface UITableView (Private)
- (CGFloat)_heightForHeaderInSection:(NSInteger)section;
- (NSString *)_titleForHeaderInSection:(NSInteger)section;
@end

@implementation IMLEXTableView

+ (instancetype)IMLEXDefaultTableView {
#if IMLEX_AT_LEAST_IOS13_SDK
    if (@available(iOS 13.0, *)) {
        return [[self alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    } else {
        return [[self alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    }
#else
    return [[self alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
#endif
}

#pragma mark - Initialization

+ (id)groupedTableView {
#if IMLEX_AT_LEAST_IOS13_SDK
    if (@available(iOS 13.0, *)) {
        return [[self alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    } else {
        return [[self alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    }
#else
    return [[self alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
#endif
}

+ (id)plainTableView {
    return [[self alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
}

+ (id)style:(UITableViewStyle)style {
    return [[self alloc] initWithFrame:CGRectZero style:style];
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self registerCells:@{
            kIMLEXDefaultCell : [IMLEXTableViewCell class],
            kIMLEXDetailCell : [IMLEXSubtitleTableViewCell class],
            kIMLEXMultilineCell : [IMLEXMultilineTableViewCell class],
            kIMLEXMultilineDetailCell : [IMLEXMultilineDetailTableViewCell class],
            kIMLEXKeyValueCell : [IMLEXKeyValueTableViewCell class],
            kIMLEXCodeFontCell : [IMLEXCodeFontCell class],
        }];
    }

    return self;
}


#pragma mark - Public

- (void)registerCells:(NSDictionary<NSString*, Class> *)registrationMapping {
    [registrationMapping enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, Class cellClass, BOOL *stop) {
        [self registerClass:cellClass forCellReuseIdentifier:identifier];
    }];
}

@end
