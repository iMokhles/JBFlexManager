//
//  IMLEXObjectRef.m
//  IMLEX
//
//  Created by Tanner Bennett on 7/24/18.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXObjectRef.h"
#import "IMLEXRuntimeUtility.h"
#import "NSArray+Functional.h"

@interface IMLEXObjectRef ()
@property (nonatomic, readonly) BOOL wantsSummary;
@end

@implementation IMLEXObjectRef
@synthesize summary = _summary;

+ (instancetype)referencing:(id)object {
    return [self referencing:object showSummary:YES];
}

+ (instancetype)referencing:(id)object showSummary:(BOOL)showSummary {
    return [[self alloc] initWithObject:object ivarName:nil showSummary:showSummary];
}

+ (instancetype)referencing:(id)object ivar:(NSString *)ivarName {
    return [[self alloc] initWithObject:object ivarName:ivarName showSummary:YES];
}

+ (NSArray<IMLEXObjectRef *> *)referencingAll:(NSArray *)objects {
    return [objects IMLEX_mapped:^id(id obj, NSUInteger idx) {
        return [self referencing:obj showSummary:YES];
    }];
}

+ (NSArray<IMLEXObjectRef *> *)referencingClasses:(NSArray<Class> *)classes {
    return [classes IMLEX_mapped:^id(id obj, NSUInteger idx) {
        return [self referencing:obj showSummary:NO];
    }];
}

- (id)initWithObject:(id)object ivarName:(NSString *)ivar showSummary:(BOOL)showSummary {
    self = [super init];
    if (self) {
        _object = object;
        _wantsSummary = showSummary;

        NSString *class = NSStringFromClass(object_getClass(object));
        if (ivar) {
            _reference = [NSString stringWithFormat:@"%@ %@", class, ivar];
        } else if (showSummary) {
            _reference = [NSString stringWithFormat:@"%@ %p", class, object];
        } else {
            _reference = class;
        }
    }

    return self;
}

- (NSString *)summary {
    if (self.wantsSummary) {
        if (!_summary) {
            _summary = [IMLEXRuntimeUtility summaryForObject:self.object];
        }
        
        return _summary;
    }
    else {
        return nil;
    }
}

@end
