//
//  IMLEXNetworkTransactionTableViewCell.h
//  Flipboard
//
//  Created by Ryan Olson on 2/8/15.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kIMLEXNetworkTransactionCellIdentifier;

@class IMLEXNetworkTransaction;

@interface IMLEXNetworkTransactionTableViewCell : UITableViewCell

@property (nonatomic) IMLEXNetworkTransaction *transaction;

+ (CGFloat)preferredCellHeight;

@end
