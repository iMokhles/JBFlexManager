//
//  IMLEXBookmarkManager.m
//  IMLEX
//
//  Created by Tanner on 2/6/20.
//  Copyright © 2020 Flipboard. All rights reserved.
//

#import "IMLEXBookmarkManager.h"

static NSMutableArray *kIMLEXBookmarkManagerBookmarks = nil;

@implementation IMLEXBookmarkManager

+ (void)initialize {
    if (self == [IMLEXBookmarkManager class]) {
        kIMLEXBookmarkManagerBookmarks = [NSMutableArray new];
    }
}

+ (NSMutableArray *)bookmarks {
    return kIMLEXBookmarkManagerBookmarks;
}

@end
