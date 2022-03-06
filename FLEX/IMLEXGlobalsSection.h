//
//  IMLEXGlobalsSection.h
//  IMLEX
//
//  Created by Tanner Bennett on 7/11/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXTableViewSection.h"
#import "IMLEXGlobalsEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMLEXGlobalsSection : IMLEXTableViewSection

+ (instancetype)title:(NSString *)title rows:(NSArray<IMLEXGlobalsEntry *> *)rows;

@end

NS_ASSUME_NONNULL_END
