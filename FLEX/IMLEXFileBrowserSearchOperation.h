//
//  IMLEXFileBrowserSearchOperation.h
//  IMLEX
//
//  Created by 啟倫 陳 on 2014/8/4.
//  Copyright (c) 2014年 f. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IMLEXFileBrowserSearchOperationDelegate;

@interface IMLEXFileBrowserSearchOperation : NSOperation

@property (nonatomic, weak) id<IMLEXFileBrowserSearchOperationDelegate> delegate;

- (id)initWithPath:(NSString *)currentPath searchString:(NSString *)searchString;

@end

@protocol IMLEXFileBrowserSearchOperationDelegate <NSObject>

- (void)fileBrowserSearchOperationResult:(NSArray<NSString *> *)searchResult size:(uint64_t)size;

@end
