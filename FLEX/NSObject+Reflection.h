//
//  NSObject+Reflection.h
//  IMLEX
//
//  Derived from MirrorKit.
//  Created by Tanner on 6/30/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
@class IMLEXMirror, IMLEXMethod, IMLEXIvar, IMLEXProperty, IMLEXMethodBase, IMLEXPropertyAttributes, IMLEXProtocol;

NS_ASSUME_NONNULL_BEGIN

/// Returns the type encoding string given the encoding for the return type and parameters, if any.
/// @discussion Example usage for a \c void returning method which takes
/// an \c int: @code IMLEXTypeEncoding(@encode(void), @encode(int));
/// @param returnType The encoded return type. \c void for exmaple would be \c @encode(void).
/// @param count The number of parameters in this type encoding string.
/// @return The type encoding string, or \c nil if \e returnType is \c NULL.
NSString * IMLEXTypeEncodingString(const char *returnType, NSUInteger count, ...);

NSArray<Class> *IMLEXGetAllSubclasses(_Nullable Class cls, BOOL includeSelf);
NSArray<Class> *IMLEXGetClassHierarchy(_Nullable Class cls, BOOL includeSelf);
NSArray<IMLEXProtocol *> *IMLEXGetConformedProtocols(_Nullable Class cls);


#pragma mark Reflection
@interface NSObject (Reflection)

@property (nonatomic, readonly       ) IMLEXMirror *IMLEX_reflection;
@property (nonatomic, readonly, class) IMLEXMirror *IMLEX_reflection;

/// Calls into /c IMLEXGetAllSubclasses
/// @return Every subclass of the receiving class, including the receiver itself.
@property (nonatomic, readonly, class) NSArray<Class> *IMLEX_allSubclasses;

/// @return The \c Class object for the metaclass of the recieving class, or \c Nil if the class is Nil or not registered.
@property (nonatomic, readonly, class) Class IMLEX_metaclass;
/// @return The size in bytes of instances of the recieving class, or \c 0 if \e cls is \c Nil.
@property (nonatomic, readonly, class) size_t IMLEX_instanceSize;

/// Changes the class of an object instance.
/// @return The previous value of the objects \c class, or \c Nil if the object is \c nil.
- (Class)IMLEX_setClass:(Class)cls;
/// Sets the recieving class's superclass. "You should not use this method" — Apple.
/// @return The old superclass.
+ (Class)IMLEX_setSuperclass:(Class)superclass;

/// Calls into \c IMLEXGetClassHierarchy()
/// @return a list of classes going up the class hierarchy,
/// starting with the receiver and ending with the root class.
@property (nonatomic, readonly, class) NSArray<Class> *IMLEX_classHierarchy;

/// Calls into \c IMLEXGetConformedProtocols
/// @return a list of protocols this class itself conforms to.
@property (nonatomic, readonly, class) NSArray<IMLEXProtocol *> *IMLEX_protocols;

@end


#pragma mark Methods
@interface NSObject (Methods)

/// All instance and class methods specific to the recieving class.
/// @discussion This method will only retrieve methods specific to the recieving class.
/// To retrieve instance variables on a parent class, simply call this on \c [self superclass].
/// @return An array of \c IMLEXMethod objects.
@property (nonatomic, readonly, class) NSArray<IMLEXMethod *> *IMLEX_allMethods;
/// All instance methods specific to the recieving class.
/// @discussion This method will only retrieve methods specific to the recieving class.
/// To retrieve instance variables on a parent class, simply call this on \c [self superclass].
/// @return An array of \c IMLEXMethod objects.
@property (nonatomic, readonly, class) NSArray<IMLEXMethod *> *IMLEX_allInstanceMethods;
/// All class methods specific to the recieving class.
/// @discussion This method will only retrieve methods specific to the recieving class.
/// To retrieve instance variables on a parent class, simply call this on \c [self superclass].
/// @return An array of \c IMLEXMethod objects.
@property (nonatomic, readonly, class) NSArray<IMLEXMethod *> *IMLEX_allClassMethods;

/// Retrieves the class's instance method with the given name.
/// @return An initialized \c IMLEXMethod object, or \c nil if the method wasn't found.
+ (IMLEXMethod *)IMLEX_methodNamed:(NSString *)name;

/// Retrieves the class's class method with the given name.
/// @return An initialized \c IMLEXMethod object, or \c nil if the method wasn't found.
+ (IMLEXMethod *)IMLEX_classMethodNamed:(NSString *)name;

/// Adds a new method to the recieving class with a given name and implementation.
/// @discussion This method will add an override of a superclass's implementation,
/// but will not replace an existing implementation in the class.
/// To change an existing implementation, use \c replaceImplementationOfMethod:with:.
///
/// Type encodings start with the return type and end with the parameter types in order.
/// The type encoding for \c NSArray's \c count property getter looks like this:
/// @code [NSString stringWithFormat:@"%s%s%s%s", @encode(void), @encode(id), @encode(SEL), @encode(NSUInteger)] @endcode
/// Using the \c IMLEXTypeEncoding function for the same method looks like this:
/// @code IMLEXTypeEncodingString(@encode(void), 1, @encode(NSUInteger)) @endcode
/// @param typeEncoding The type encoding string. Consider using the \c IMLEXTypeEncodingString() function.
/// @param instanceMethod NO to add the method to the class itself or YES to add it as an instance method.
/// @return YES if the method was added successfully, \c NO otherwise
/// (for example, the class already contains a method implementation with that name).
+ (BOOL)addMethod:(SEL)selector
     typeEncoding:(NSString *)typeEncoding
   implementation:(IMP)implementaiton
      toInstances:(BOOL)instanceMethod;

/// Replaces the implementation of a method in the recieving class.
/// @param instanceMethod YES to replace the instance method, NO to replace the class method.
/// @note This function behaves in two different ways:
///
/// - If the method does not yet exist in the recieving class, it is added as if
/// \c addMethod:typeEncoding:implementation were called.
///
/// - If the method does exist, its \c IMP is replaced.
/// @return The previous \c IMP of \e method.
+ (IMP)replaceImplementationOfMethod:(IMLEXMethodBase *)method with:(IMP)implementation useInstance:(BOOL)instanceMethod;
/// Swaps the implementations of the given methods.
/// @discussion If one or neither of the given methods exist in the recieving class,
/// they are added to the class with their implementations swapped as if each method did exist.
/// This method will not fail if each \c IMLEXSimpleMethod contains a valid selector.
/// @param instanceMethod YES to swizzle the instance method, NO to swizzle the class method.
+ (void)swizzle:(IMLEXMethodBase *)original with:(IMLEXMethodBase *)other onInstance:(BOOL)instanceMethod;
/// Swaps the implementations of the given methods.
/// @param instanceMethod YES to swizzle the instance method, NO to swizzle the class method.
/// @return \c YES if successful, and \c NO if selectors could not be retrieved from the given strings.
+ (BOOL)swizzleByName:(NSString *)original with:(NSString *)other onInstance:(BOOL)instanceMethod;
/// Swaps the implementations of methods corresponding to the given selectors.
+ (void)swizzleBySelector:(SEL)original with:(SEL)other onInstance:(BOOL)instanceMethod;

@end


#pragma mark Properties
@interface NSObject (Ivars)

/// All of the instance variables specific to the recieving class.
/// @discussion This method will only retrieve instance varibles specific to the recieving class.
/// To retrieve instance variables on a parent class, simply call \c [[self superclass] allIvars].
/// @return An array of \c IMLEXIvar objects.
@property (nonatomic, readonly, class) NSArray<IMLEXIvar *> *IMLEX_allIvars;

/// Retrieves an instance variable with the corresponding name.
/// @return An initialized \c IMLEXIvar object, or \c nil if the Ivar wasn't found.
+ (IMLEXIvar *)IMLEX_ivarNamed:(NSString *)name;

/// @return The address of the given ivar in the recieving object in memory,
/// or \c NULL if it could not be found.
- (void *)IMLEX_getIvarAddress:(IMLEXIvar *)ivar;
/// @return The address of the given ivar in the recieving object in memory,
/// or \c NULL if it could not be found.
- (void *)IMLEX_getIvarAddressByName:(NSString *)name;
/// @discussion This method faster than creating an \c IMLEXIvar and calling
/// \c -getIvarAddress: if you already have an \c Ivar on hand
/// @return The address of the given ivar in the recieving object in memory,
/// or \c NULL if it could not be found\.
- (void *)IMLEX_getObjcIvarAddress:(Ivar)ivar;

/// Sets the value of the given instance variable on the recieving object.
/// @discussion Use only when the target instance variable is an object.
- (void)IMLEX_setIvar:(IMLEXIvar *)ivar object:(id)value;
/// Sets the value of the given instance variable on the recieving object.
/// @discussion Use only when the target instance variable is an object.
/// @return \c YES if successful, or \c NO if the instance variable could not be found.
- (BOOL)IMLEX_setIvarByName:(NSString *)name object:(id)value;
/// @discussion Use only when the target instance variable is an object.
/// This method is faster than creating an \c IMLEXIvar and calling
/// \c -setIvar: if you already have an \c Ivar on hand.
- (void)IMLEX_setObjcIvar:(Ivar)ivar object:(id)value;

/// Sets the value of the given instance variable on the recieving object to the
/// \e size number of bytes of data at \e value.
/// @discussion Use one of the other methods if you can help it.
- (void)IMLEX_setIvar:(IMLEXIvar *)ivar value:(void *)value size:(size_t)size;
/// Sets the value of the given instance variable on the recieving object to the
/// \e size number of bytes of data at \e value.
/// @discussion Use one of the other methods if you can help it
/// @return \c YES if successful, or \c NO if the instance variable could not be found.
- (BOOL)IMLEX_setIvarByName:(NSString *)name value:(void *)value size:(size_t)size;
/// Sets the value of the given instance variable on the recieving object to the
/// \e size number of bytes of data at \e value.
/// @discussion This is faster than creating an \c IMLEXIvar and calling
/// \c -setIvar:value:size if you already have an \c Ivar on hand.
- (void)IMLEX_setObjcIvar:(Ivar)ivar value:(void *)value size:(size_t)size;

@end

#pragma mark Properties
@interface NSObject (Properties)

/// All instance and class properties specific to the recieving class.
/// @discussion This method will only retrieve properties specific to the recieving class.
/// To retrieve instance variables on a parent class, simply call this on \c [self superclass].
/// @return An array of \c IMLEXProperty objects.
@property (nonatomic, readonly, class) NSArray<IMLEXProperty *> *IMLEX_allProperties;
/// All instance properties specific to the recieving class.
/// @discussion This method will only retrieve properties specific to the recieving class.
/// To retrieve instance variables on a parent class, simply call this on \c [self superclass].
/// @return An array of \c IMLEXProperty objects.
@property (nonatomic, readonly, class) NSArray<IMLEXProperty *> *IMLEX_allInstanceProperties;
/// All class properties specific to the recieving class.
/// @discussion This method will only retrieve properties specific to the recieving class.
/// To retrieve instance variables on a parent class, simply call this on \c [self superclass].
/// @return An array of \c IMLEXProperty objects.
@property (nonatomic, readonly, class) NSArray<IMLEXProperty *> *IMLEX_allClassProperties;

/// Retrieves the class's property with the given name.
/// @return An initialized \c IMLEXProperty object, or \c nil if the property wasn't found.
+ (IMLEXProperty *)IMLEX_propertyNamed:(NSString *)name;
/// @return An initialized \c IMLEXProperty object, or \c nil if the property wasn't found.
+ (IMLEXProperty *)IMLEX_classPropertyNamed:(NSString *)name;

/// Replaces the given property on the recieving class.
+ (void)IMLEX_replaceProperty:(IMLEXProperty *)property;
/// Replaces the given property on the recieving class. Useful for changing a property's attributes.
+ (void)IMLEX_replaceProperty:(NSString *)name attributes:(IMLEXPropertyAttributes *)attributes;

@end

NS_ASSUME_NONNULL_END
