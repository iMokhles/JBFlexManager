//
//  IMLEXDBQueryRowCell.h
//  IMLEX
//
//  Created by Peng Tao on 15/11/24.
//  Copyright © 2015年 f. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kIMLEXDBQueryRowCellReuse;


@interface IMLEXDBQueryRowCell : UITableViewCell

/// An array of NSString, NSNumber, or NSData objects
@property (nonatomic) NSArray *data;

@end
