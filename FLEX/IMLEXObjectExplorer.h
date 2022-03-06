//
//  IMLEXObjectExplorer.h
//  IMLEX
//
//  Created by Tanner Bennett on 8/28/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXRuntime+UIKitHelpers.h"

@interface IMLEXObjectExplorer : NSObject

+ (instancetype)forObject:(id)objectOrClass;

@property (nonatomic, readonly) id object;
/// Subclasses can override to provide a more useful description
@property (nonatomic, readonly) NSString *objectDescription;

/// @return \c YES if \c object is an instance of a class,
/// or \c NO if \c object is a class itself.
@property (nonatomic, readonly) BOOL objectIsInstance;

/// An index into the `classHierarchy` array.
///
/// This property determines which set of data comes out of the metadata arrays below
/// For example, \c properties contains the properties of the selected class scope,
/// while \c allProperties is an array of arrays where each array is a set of
/// properties for a class in the class hierarchy of the current object.
@property (nonatomic) NSInteger classScope;

@property (nonatomic, readonly) NSArray<NSArray<IMLEXProperty *> *> *allProperties;
@property (nonatomic, readonly) NSArray<IMLEXProperty *> *properties;

@property (nonatomic, readonly) NSArray<NSArray<IMLEXProperty *> *> *allClassProperties;
@property (nonatomic, readonly) NSArray<IMLEXProperty *> *classProperties;

@property (nonatomic, readonly) NSArray<NSArray<IMLEXIvar *> *> *allIvars;
@property (nonatomic, readonly) NSArray<IMLEXIvar *> *ivars;

@property (nonatomic, readonly) NSArray<NSArray<IMLEXMethod *> *> *allMethods;
@property (nonatomic, readonly) NSArray<IMLEXMethod *> *methods;

@property (nonatomic, readonly) NSArray<NSArray<IMLEXMethod *> *> *allClassMethods;
@property (nonatomic, readonly) NSArray<IMLEXMethod *> *classMethods;

@property (nonatomic, readonly) NSArray<Class> *classHierarchyClasses;
@property (nonatomic, readonly) NSArray<IMLEXStaticMetadata *> *classHierarchy;

@property (nonatomic, readonly) NSArray<NSArray<IMLEXProtocol *> *> *allConformedProtocols;
@property (nonatomic, readonly) NSArray<IMLEXProtocol *> *conformedProtocols;

@property (nonatomic, readonly) NSArray<IMLEXStaticMetadata *> *allInstanceSizes;
@property (nonatomic, readonly) IMLEXStaticMetadata *instanceSize;

@property (nonatomic, readonly) NSArray<IMLEXStaticMetadata *> *allImageNames;
@property (nonatomic, readonly) IMLEXStaticMetadata *imageName;

- (void)reloadMetadata;
- (void)reloadClassHierarchy;

@end
