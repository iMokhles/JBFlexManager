//
//  IMLEXManager+Private.h
//  PebbleApp
//
//  Created by Javier Soto on 7/26/14.
//  Copyright (c) 2014 Pebble Technology. All rights reserved.
//

#import "IMLEXManager.h"
#import "IMLEXWindow.h"

@class IMLEXGlobalsEntry, IMLEXExplorerViewController;

@interface IMLEXManager (Private)

@property (nonatomic, readonly) IMLEXWindow *explorerWindow;
@property (nonatomic, readonly) IMLEXExplorerViewController *explorerViewController;

/// An array of IMLEXGlobalsEntry objects that have been registered by the user.
@property (nonatomic, readonly) NSMutableArray<IMLEXGlobalsEntry *> *userGlobalEntries;
@property (nonatomic, readonly) NSMutableDictionary<NSString *, IMLEXCustomContentViewerFuture> *customContentTypeViewers;

@end
