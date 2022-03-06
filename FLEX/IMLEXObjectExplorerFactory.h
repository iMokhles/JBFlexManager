//
//  IMLEXObjectExplorerFactory.h
//  Flipboard
//
//  Created by Ryan Olson on 5/15/14.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXGlobalsEntry.h"

#ifndef _IMLEXObjectExplorerViewController_h
#import "IMLEXObjectExplorerViewController.h"
#else
@class IMLEXObjectExplorerViewController;
#endif

NS_ASSUME_NONNULL_BEGIN

@interface IMLEXObjectExplorerFactory : NSObject <IMLEXGlobalsEntry>

+ (nullable IMLEXObjectExplorerViewController *)explorerViewControllerForObject:(nullable id)object;

/// Register a specific explorer view controller class to be used when exploring
/// an object of a specific class. Calls will overwrite existing registrations.
/// Sections must be initialized using \c forObject: like
+ (void)registerExplorerSection:(Class)sectionClass forClass:(Class)objectClass;

@end

NS_ASSUME_NONNULL_END
