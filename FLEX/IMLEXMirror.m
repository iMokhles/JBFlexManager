//
//  IMLEXMirror.m
//  IMLEX
//
//  Derived from MirrorKit.
//  Created by Tanner on 6/29/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "IMLEXMirror.h"
#import "IMLEXProperty.h"
#import "IMLEXMethod.h"
#import "IMLEXIvar.h"
#import "IMLEXProtocol.h"
#import "IMLEXUtility.h"


#pragma mark IMLEXMirror

@implementation IMLEXMirror

- (id)init {
    [NSException
        raise:NSInternalInconsistencyException
        format:@"Class instance should not be created with -init"
    ];
    return nil;
}

#pragma mark Initialization
+ (instancetype)reflect:(id)objectOrClass {
    return [[self alloc] initWithValue:objectOrClass];
}

- (id)initWithValue:(id)value {
    NSParameterAssert(value);
    
    self = [super init];
    if (self) {
        _value = value;
        [self examine];
    }
    
    return self;
}

- (NSString *)description {
    NSString *type = self.isClass ? @"metaclass" : @"class";
    return [NSString
        stringWithFormat:@"<%@ %@=%@, %lu properties, %lu ivars, %lu methods, %lu protocols>",
        NSStringFromClass(self.class),
        type,
        self.className,
        (unsigned long)self.properties.count,
        (unsigned long)self.ivars.count,
        (unsigned long)self.methods.count,
        (unsigned long)self.protocols.count
    ];
}

- (void)examine {
    // cls is a metaclass if self.value is a class
    Class cls = object_getClass(self.value);
    
    unsigned int pcount, mcount, ivcount, pccount;
    objc_property_t *objcproperties     = class_copyPropertyList(cls, &pcount);
    Protocol*__unsafe_unretained *procs = class_copyProtocolList(cls, &pccount);
    Method *objcmethods                 = class_copyMethodList(cls, &mcount);
    Ivar *objcivars                     = class_copyIvarList(cls, &ivcount);
    
    _className = NSStringFromClass(cls);
    _isClass   = class_isMetaClass(cls); // or object_isClass(self.value)
    
    NSMutableArray *properties = [NSMutableArray new];
    for (int i = 0; i < pcount; i++)
        [properties addObject:[IMLEXProperty property:objcproperties[i]]];
    _properties = properties;
    
    NSMutableArray *methods = [NSMutableArray new];
    for (int i = 0; i < mcount; i++)
        [methods addObject:[IMLEXMethod method:objcmethods[i]]];
    _methods = methods;
    
    NSMutableArray *ivars = [NSMutableArray new];
    for (int i = 0; i < ivcount; i++)
        [ivars addObject:[IMLEXIvar ivar:objcivars[i]]];
    _ivars = ivars;
    
    NSMutableArray *protocols = [NSMutableArray new];
    for (int i = 0; i < pccount; i++)
        [protocols addObject:[IMLEXProtocol protocol:procs[i]]];
    _protocols = protocols;
    
    // Cleanup
    free(objcproperties);
    free(objcmethods);
    free(objcivars);
    free(procs);
    procs = NULL;
}

#pragma mark Misc

- (IMLEXMirror *)superMirror {
    return [IMLEXMirror reflect:[self.value superclass]];
}

@end


#pragma mark ExtendedMirror

@implementation IMLEXMirror (ExtendedMirror)

- (id)filter:(NSArray *)array forName:(NSString *)name {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K = %@", @"name", name];
    return [array filteredArrayUsingPredicate:filter].firstObject;
}

- (IMLEXMethod *)methodNamed:(NSString *)name {
    return [self filter:self.methods forName:name];
}

- (IMLEXProperty *)propertyNamed:(NSString *)name {
    return [self filter:self.properties forName:name];
}

- (IMLEXIvar *)ivarNamed:(NSString *)name {
    return [self filter:self.ivars forName:name];
}

- (IMLEXProtocol *)protocolNamed:(NSString *)name {
    return [self filter:self.protocols forName:name];
}

@end
