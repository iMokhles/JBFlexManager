//
//  IMLEXMirror.h
//  IMLEX
//
//  Derived from MirrorKit.
//  Created by Tanner on 6/29/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IMLEXMethod, IMLEXProperty, IMLEXIvar, IMLEXProtocol;
#import <objc/runtime.h>


#pragma mark IMLEXMirror
@interface IMLEXMirror : NSObject

/// Reflects an instance of an object or \c Class.
/// @discussion \c IMLEXMirror will immediately gather all useful information. Consider using the
/// \c NSObject categories provided if your code will only use a few pieces of information,
/// or if your code needs to run faster.
///
/// If you reflect an instance of a class then \c methods and \c properties will be populated
/// with instance methods and properties. If you reflect a class itself, then \c methods
/// and \c properties will be populated with class methods and properties as you'd expect.
///
/// @param objectOrClass An instance of an objct or a \c Class object.
/// @return An instance of \c IMLEXMirror.
+ (instancetype)reflect:(id)objectOrClass;

/// The underlying object or \c Class used to create this \c IMLEXMirror instance.
@property (nonatomic, readonly) id   value;
/// Whether the reflected thing was a class or a class instance.
@property (nonatomic, readonly) BOOL isClass;
/// The name of the \c Class of the \c value property.
@property (nonatomic, readonly) NSString *className;

@property (nonatomic, readonly) NSArray<IMLEXProperty *> *properties;
@property (nonatomic, readonly) NSArray<IMLEXIvar *>     *ivars;
@property (nonatomic, readonly) NSArray<IMLEXMethod *>   *methods;
@property (nonatomic, readonly) NSArray<IMLEXProtocol *> *protocols;

/// @return A reflection of \c value.superClass.
@property (nonatomic, readonly) IMLEXMirror *superMirror;

@end


@interface IMLEXMirror (ExtendedMirror)

/// @return The method with the given name, or \c nil if one does not exist.
- (IMLEXMethod *)methodNamed:(NSString *)name;
/// @return The property with the given name, or \c nil if one does not exist.
- (IMLEXProperty *)propertyNamed:(NSString *)name;
/// @return The instance variable with the given name, or \c nil if one does not exist.
- (IMLEXIvar *)ivarNamed:(NSString *)name;
/// @return The protocol with the given name, or \c nil if one does not exist.
- (IMLEXProtocol *)protocolNamed:(NSString *)name;

@end
