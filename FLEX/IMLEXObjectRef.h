//
//  IMLEXObjectRef.h
//  IMLEX
//
//  Created by Tanner Bennett on 7/24/18.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMLEXObjectRef : NSObject

+ (instancetype)referencing:(id)object;
+ (instancetype)referencing:(id)object ivar:(NSString *)ivarName;

+ (NSArray<IMLEXObjectRef *> *)referencingAll:(NSArray *)objects;
/// Classes do not have a summary, and the reference is just the class name.
+ (NSArray<IMLEXObjectRef *> *)referencingClasses:(NSArray<Class> *)classes;

/// For example, "NSString 0x1d4085d0" or "NSLayoutConstraint _object"
@property (nonatomic, readonly) NSString *reference;
/// For instances, this is the result of -[IMLEXRuntimeUtility summaryForObject:]
/// For classes, there is no summary.
@property (nonatomic, readonly) NSString *summary;
@property (nonatomic, readonly) id object;

@end
