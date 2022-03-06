//
//  IMLEXProtocol.h
//  IMLEX
//
//  Derived from MirrorKit.
//  Created by Tanner on 6/30/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "IMLEXRuntimeConstants.h"
@class IMLEXProperty, IMLEXMethodDescription;

#pragma mark IMLEXProtocol
@interface IMLEXProtocol : NSObject

/// Every protocol registered with the runtime.
+ (NSArray<IMLEXProtocol *> *)allProtocols;
+ (instancetype)protocol:(Protocol *)protocol;

/// The underlying protocol data structure.
@property (nonatomic, readonly) Protocol *objc_protocol;

/// The name of the protocol.
@property (nonatomic, readonly) NSString *name;
/// The properties in the protocol, if any.
@property (nonatomic, readonly) NSArray<IMLEXProperty *>  *properties;
/// The required methods of the protocol, if any. This includes property getters and setters.
@property (nonatomic, readonly) NSArray<IMLEXMethodDescription *>  *requiredMethods;
/// The optional methods of the protocol, if any. This includes property getters and setters.
@property (nonatomic, readonly) NSArray<IMLEXMethodDescription *>  *optionalMethods;
/// All protocols that this protocol conforms to, if any.
@property (nonatomic, readonly) NSArray<IMLEXProtocol *>  *protocols;

/// For internal use
@property (nonatomic) id tag;

/// Not to be confused with \c -conformsToProtocol:, which refers to the current
/// \c IMLEXProtocol instance and not the underlying \c Protocol object.
- (BOOL)conformsTo:(Protocol *)protocol;

@end


#pragma mark Method descriptions
@interface IMLEXMethodDescription : NSObject

+ (instancetype)description:(struct objc_method_description)methodDescription;

/// The underlying method description data structure.
@property (nonatomic, readonly) struct objc_method_description objc_description;
/// The method's selector.
@property (nonatomic, readonly) SEL selector;
/// The method's type encoding.
@property (nonatomic, readonly) NSString *typeEncoding;
/// The method's return type.
@property (nonatomic, readonly) IMLEXTypeEncoding returnType;
@end
