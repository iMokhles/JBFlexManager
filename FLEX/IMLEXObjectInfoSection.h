//
//  IMLEXObjectInfoSection.h
//  IMLEX
//
//  Created by Tanner Bennett on 8/28/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

/// \c IMLEXTableViewSection itself doesn't know about the object being explored.
/// Subclasses might need this info to provide useful information about the object. Instead
/// of adding an abstract class to the class hierarchy, subclasses can conform to this protocol
/// to indicate that the only info they need to be initialized is the object being explored.
@protocol IMLEXObjectInfoSection <NSObject>

+ (instancetype)forObject:(id)object;

@end
