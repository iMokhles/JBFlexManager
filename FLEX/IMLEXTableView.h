//
//  IMLEXTableView.h
//  IMLEX
//
//  Created by Tanner on 4/17/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark Reuse identifiers

typedef NSString * IMLEXTableViewCellReuseIdentifier;

/// A regular \c IMLEXTableViewCell initialized with \c UITableViewCellStyleDefault
extern IMLEXTableViewCellReuseIdentifier const kIMLEXDefaultCell;
/// A \c IMLEXSubtitleTableViewCell initialized with \c UITableViewCellStyleSubtitle
extern IMLEXTableViewCellReuseIdentifier const kIMLEXDetailCell;
/// A \c IMLEXMultilineTableViewCell initialized with \c UITableViewCellStyleDefault
extern IMLEXTableViewCellReuseIdentifier const kIMLEXMultilineCell;
/// A \c IMLEXMultilineTableViewCell initialized with \c UITableViewCellStyleSubtitle
extern IMLEXTableViewCellReuseIdentifier const kIMLEXMultilineDetailCell;
/// A \c IMLEXTableViewCell initialized with \c UITableViewCellStyleValue1
extern IMLEXTableViewCellReuseIdentifier const kIMLEXKeyValueCell;
/// A \c IMLEXSubtitleTableViewCell which uses monospaced fonts for both labels
extern IMLEXTableViewCellReuseIdentifier const kIMLEXCodeFontCell;

#pragma mark - IMLEXTableView
@interface IMLEXTableView : UITableView

+ (instancetype)IMLEXDefaultTableView;
+ (instancetype)groupedTableView;
+ (instancetype)plainTableView;
+ (instancetype)style:(UITableViewStyle)style;

/// You do not need to register classes for any of the default reuse identifiers above
/// (annotated as \c IMLEXTableViewCellReuseIdentifier types) unless you wish to provide
/// a custom cell for any of those reuse identifiers. By default, \c IMLEXTableViewCell,
/// \c IMLEXSubtitleTableViewCell, and \c IMLEXMultilineTableViewCell are used, respectively.
///
/// @param registrationMapping A map of reuse identifiers to \c UITableViewCell (sub)class objects.
- (void)registerCells:(NSDictionary<NSString *, Class> *)registrationMapping;

@end

NS_ASSUME_NONNULL_END
