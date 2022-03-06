//
//  NSObject+Reflection.m
//  IMLEX
//
//  Derived from MirrorKit.
//  Created by Tanner on 6/30/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSObject+Reflection.h"
#import "IMLEXClassBuilder.h"
#import "IMLEXMirror.h"
#import "IMLEXProperty.h"
#import "IMLEXMethod.h"
#import "IMLEXIvar.h"
#import "IMLEXProtocol.h"
#import "IMLEXPropertyAttributes.h"
#import "NSArray+Functional.h"
#import "IMLEXUtility.h"


NSString * IMLEXTypeEncodingString(const char *returnType, NSUInteger count, ...) {
    if (returnType == NULL) return nil;
    
    NSMutableString *encoding = [NSMutableString new];
    [encoding appendFormat:@"%s%s%s", returnType, @encode(id), @encode(SEL)];
    
    va_list args;
    va_start(args, count);
    char *type = va_arg(args, char *);
    for (NSUInteger i = 0; i < count; i++, type = va_arg(args, char *)) {
        [encoding appendFormat:@"%s", type];
    }
    va_end(args);
    
    return encoding.copy;
}

NSArray<Class> *IMLEXGetAllSubclasses(Class cls, BOOL includeSelf) {
    if (!cls) {
        return nil;
    }
    
    Class *buffer = NULL;
    
    int count, size;
    do {
        count  = objc_getClassList(NULL, 0);
        buffer = (Class *)realloc(buffer, count * sizeof(*buffer));
        size   = objc_getClassList(buffer, count);
    } while (size != count);
    
    NSMutableArray *classes = [NSMutableArray new];
    if (includeSelf) {
        [classes addObject:cls];
    }
    
    for (int i = 0; i < count; i++) {
        Class candidate = buffer[i];
        Class superclass = candidate;
        while ((superclass = class_getSuperclass(superclass))) {
            if (superclass == cls) {
                [classes addObject:candidate];
                break;
            }
        }
    }
    
    free(buffer);
    return classes.copy;
}

NSArray<Class> *IMLEXGetClassHierarchy(Class cls, BOOL includeSelf) {
    if (!cls) {
        return nil;
    }
    
    NSMutableArray *classes = [NSMutableArray new];
    if (includeSelf) {
        [classes addObject:cls];
    }
    
    while ((cls = [cls superclass])) {
        [classes addObject:cls];
    };

    return classes.copy;
}

NSArray<IMLEXProtocol *> *IMLEXGetConformedProtocols(Class cls) {
    if (!cls) {
        return nil;
    }
    
    unsigned int count = 0;
    Protocol *__unsafe_unretained *list = class_copyProtocolList(cls, &count);
    NSArray<Protocol *> *protocols = [NSArray arrayWithObjects:list count:count];
    
    return [protocols IMLEX_mapped:^id(Protocol *pro, NSUInteger idx) {
        return [IMLEXProtocol protocol:pro];
    }];
}


#pragma mark NSProxy

@interface NSProxy (AnyObjectAdditions) @end
@implementation NSProxy (AnyObjectAdditions)

+ (void)load { IMLEX_EXIT_IF_TESTING()
    // We need to get all of the methods in this file and add them to NSProxy. 
    // To do this we we need the class itself and it's metaclass.
    // Edit: also add them to Swift._SwiftObject
    Class NSProxyClass = [NSProxy class];
    Class NSProxy_meta = object_getClass(NSProxyClass);
    Class SwiftObjectClass = (
        NSClassFromString(@"SwiftObject") ?: NSClassFromString(@"Swift._SwiftObject")
    );
    
    // Copy all of the "IMLEX_" methods from NSObject
    id filterFunc = ^BOOL(IMLEXMethod *method, NSUInteger idx) {
        return [method.name hasPrefix:@"IMLEX_"];
    };
    NSArray *instanceMethods = [NSObject.IMLEX_allInstanceMethods IMLEX_filtered:filterFunc];
    NSArray *classMethods = [NSObject.IMLEX_allClassMethods IMLEX_filtered:filterFunc];
    
    IMLEXClassBuilder *proxy     = [IMLEXClassBuilder builderForClass:NSProxyClass];
    IMLEXClassBuilder *proxyMeta = [IMLEXClassBuilder builderForClass:NSProxy_meta];
    [proxy addMethods:instanceMethods];
    [proxyMeta addMethods:classMethods];
    
    if (SwiftObjectClass) {
        Class SwiftObject_meta = object_getClass(SwiftObjectClass);
        IMLEXClassBuilder *swiftObject = [IMLEXClassBuilder builderForClass:SwiftObjectClass];
        IMLEXClassBuilder *swiftObjectMeta = [IMLEXClassBuilder builderForClass:SwiftObject_meta];
        [swiftObject addMethods:instanceMethods];
        [swiftObjectMeta addMethods:classMethods];
    }
}

@end

#pragma mark Reflection

@implementation NSObject (Reflection)

+ (IMLEXMirror *)IMLEX_reflection {
    return [IMLEXMirror reflect:self];
}

- (IMLEXMirror *)IMLEX_reflection {
    return [IMLEXMirror reflect:self];
}

/// Code borrowed from MAObjCRuntime by Mike Ash
+ (NSArray *)IMLEX_allSubclasses {
    return IMLEXGetAllSubclasses(self, YES);
}

- (Class)IMLEX_setClass:(Class)cls {
    return object_setClass(self, cls);
}

+ (Class)IMLEX_metaclass {
    return objc_getMetaClass(NSStringFromClass(self.class).UTF8String);
}

+ (size_t)IMLEX_instanceSize {
    return class_getInstanceSize(self.class);
}

+ (Class)IMLEX_setSuperclass:(Class)superclass {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return class_setSuperclass(self, superclass);
    #pragma clang diagnostic pop
}

+ (NSArray<Class> *)IMLEX_classHierarchy {
    return IMLEXGetClassHierarchy(self, YES);
}

+ (NSArray<IMLEXProtocol *> *)IMLEX_protocols {
    return IMLEXGetConformedProtocols(self);
}

@end


#pragma mark Methods

@implementation NSObject (Methods)

+ (NSArray<IMLEXMethod *> *)IMLEX_allMethods {
    NSMutableArray *instanceMethods = (id)self.IMLEX_allInstanceMethods;
    [instanceMethods addObjectsFromArray:self.IMLEX_allClassMethods];
    return instanceMethods;
}

+ (NSArray<IMLEXMethod *> *)IMLEX_allInstanceMethods {
    unsigned int mcount;
    Method *objcmethods = class_copyMethodList([self class], &mcount);

    NSMutableArray *methods = [NSMutableArray new];
    for (int i = 0; i < mcount; i++) {
        IMLEXMethod *m = [IMLEXMethod method:objcmethods[i] isInstanceMethod:YES];
        if (m) {
            [methods addObject:m];
        }
    }

    free(objcmethods);
    return methods;
}

+ (NSArray<IMLEXMethod *> *)IMLEX_allClassMethods {
    unsigned int mcount;
    Method *objcmethods = class_copyMethodList(self.IMLEX_metaclass, &mcount);

    NSMutableArray *methods = [NSMutableArray new];
    for (int i = 0; i < mcount; i++) {
        IMLEXMethod *m = [IMLEXMethod method:objcmethods[i] isInstanceMethod:NO];
        if (m) {
            [methods addObject:m];
        }
    }

    free(objcmethods);
    return methods;
}

+ (IMLEXMethod *)IMLEX_methodNamed:(NSString *)name {
    Method m = class_getInstanceMethod([self class], NSSelectorFromString(name));
    if (m == NULL) {
        return nil;
    }

    return [IMLEXMethod method:m isInstanceMethod:YES];
}

+ (IMLEXMethod *)IMLEX_classMethodNamed:(NSString *)name {
    Method m = class_getClassMethod([self class], NSSelectorFromString(name));
    if (m == NULL) {
        return nil;
    }

    return [IMLEXMethod method:m isInstanceMethod:NO];
}

+ (BOOL)addMethod:(SEL)selector
     typeEncoding:(NSString *)typeEncoding
   implementation:(IMP)implementaiton
      toInstances:(BOOL)instance {
    return class_addMethod(instance ? self.class : self.IMLEX_metaclass, selector, implementaiton, typeEncoding.UTF8String);
}

+ (IMP)replaceImplementationOfMethod:(IMLEXMethodBase *)method with:(IMP)implementation useInstance:(BOOL)instance {
    return class_replaceMethod(instance ? self.class : self.IMLEX_metaclass, method.selector, implementation, method.typeEncoding.UTF8String);
}

+ (void)swizzle:(IMLEXMethodBase *)original with:(IMLEXMethodBase *)other onInstance:(BOOL)instance {
    [self swizzleBySelector:original.selector with:other.selector onInstance:instance];
}

+ (BOOL)swizzleByName:(NSString *)original with:(NSString *)other onInstance:(BOOL)instance {
    SEL originalMethod = NSSelectorFromString(original);
    SEL newMethod      = NSSelectorFromString(other);
    if (originalMethod == 0 || newMethod == 0) {
        return NO;
    }

    [self swizzleBySelector:originalMethod with:newMethod onInstance:instance];
    return YES;
}

+ (void)swizzleBySelector:(SEL)original with:(SEL)other onInstance:(BOOL)instance {
    Class cls = instance ? self.class : self.IMLEX_metaclass;
    Method originalMethod = class_getInstanceMethod(cls, original);
    Method newMethod = class_getInstanceMethod(cls, other);
    if (class_addMethod(cls, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(cls, other, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

@end


#pragma mark Ivars

@implementation NSObject (Ivars)

+ (NSArray<IMLEXIvar *> *)IMLEX_allIvars {
    unsigned int ivcount;
    Ivar *objcivars = class_copyIvarList([self class], &ivcount);
    
    NSMutableArray *ivars = [NSMutableArray new];
    for (int i = 0; i < ivcount; i++) {
        [ivars addObject:[IMLEXIvar ivar:objcivars[i]]];
    }

    free(objcivars);
    return ivars;
}

+ (IMLEXIvar *)IMLEX_ivarNamed:(NSString *)name {
    Ivar i = class_getInstanceVariable([self class], name.UTF8String);
    if (i == NULL) {
        return nil;
    }

    return [IMLEXIvar ivar:i];
}

#pragma mark Get address
- (void *)IMLEX_getIvarAddress:(IMLEXIvar *)ivar {
    return (uint8_t *)(__bridge void *)self + ivar.offset;
}

- (void *)IMLEX_getObjcIvarAddress:(Ivar)ivar {
    return (uint8_t *)(__bridge void *)self + ivar_getOffset(ivar);
}

- (void *)IMLEX_getIvarAddressByName:(NSString *)name {
    Ivar ivar = class_getInstanceVariable(self.class, name.UTF8String);
    if (!ivar) return 0;
    
    return (uint8_t *)(__bridge void *)self + ivar_getOffset(ivar);
}

#pragma mark Set ivar object
- (void)IMLEX_setIvar:(IMLEXIvar *)ivar object:(id)value {
    object_setIvar(self, ivar.objc_ivar, value);
}

- (BOOL)IMLEX_setIvarByName:(NSString *)name object:(id)value {
    Ivar ivar = class_getInstanceVariable(self.class, name.UTF8String);
    if (!ivar) return NO;
    
    object_setIvar(self, ivar, value);
    return YES;
}

- (void)IMLEX_setObjcIvar:(Ivar)ivar object:(id)value {
    object_setIvar(self, ivar, value);
}

#pragma mark Set ivar value
- (void)IMLEX_setIvar:(IMLEXIvar *)ivar value:(void *)value size:(size_t)size {
    void *address = [self IMLEX_getIvarAddress:ivar];
    memcpy(address, value, size);
}

- (BOOL)IMLEX_setIvarByName:(NSString *)name value:(void *)value size:(size_t)size {
    Ivar ivar = class_getInstanceVariable(self.class, name.UTF8String);
    if (!ivar) return NO;
    
    [self IMLEX_setObjcIvar:ivar value:value size:size];
    return YES;
}

- (void)IMLEX_setObjcIvar:(Ivar)ivar value:(void *)value size:(size_t)size {
    void *address = [self IMLEX_getObjcIvarAddress:ivar];
    memcpy(address, value, size);
}

@end


#pragma mark Properties

@implementation NSObject (Properties)

+ (NSArray<IMLEXProperty *> *)IMLEX_allProperties {
    NSMutableArray *instanceProperties = (id)self.IMLEX_allInstanceProperties;
    [instanceProperties addObjectsFromArray:self.IMLEX_allClassProperties];
    return instanceProperties;
}

+ (NSArray<IMLEXProperty *> *)IMLEX_allInstanceProperties {
    unsigned int pcount;
    objc_property_t *objcproperties = class_copyPropertyList(self, &pcount);
    
    NSMutableArray *properties = [NSMutableArray new];
    for (int i = 0; i < pcount; i++) {
        [properties addObject:[IMLEXProperty property:objcproperties[i] onClass:self]];
    }

    free(objcproperties);
    return properties;
}

+ (NSArray<IMLEXProperty *> *)IMLEX_allClassProperties {
    Class metaclass = self.IMLEX_metaclass;
    unsigned int pcount;
    objc_property_t *objcproperties = class_copyPropertyList(metaclass, &pcount);

    NSMutableArray *properties = [NSMutableArray new];
    for (int i = 0; i < pcount; i++) {
        [properties addObject:[IMLEXProperty property:objcproperties[i] onClass:metaclass]];
    }

    free(objcproperties);
    return properties;
}

+ (IMLEXProperty *)IMLEX_propertyNamed:(NSString *)name {
    objc_property_t p = class_getProperty([self class], name.UTF8String);
    if (p == NULL) {
        return nil;
    }

    return [IMLEXProperty property:p onClass:self];
}

+ (IMLEXProperty *)IMLEX_classPropertyNamed:(NSString *)name {
    objc_property_t p = class_getProperty(object_getClass(self), name.UTF8String);
    if (p == NULL) {
        return nil;
    }

    return [IMLEXProperty property:p onClass:object_getClass(self)];
}

+ (void)IMLEX_replaceProperty:(IMLEXProperty *)property {
    [self IMLEX_replaceProperty:property.name attributes:property.attributes];
}

+ (void)IMLEX_replaceProperty:(NSString *)name attributes:(IMLEXPropertyAttributes *)attributes {
    unsigned int count;
    objc_property_attribute_t *objc_attributes = [attributes copyAttributesList:&count];
    class_replaceProperty([self class], name.UTF8String, objc_attributes, count);
    free(objc_attributes);
}

@end


