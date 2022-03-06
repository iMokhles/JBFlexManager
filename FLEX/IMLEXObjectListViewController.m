//
//  IMLEXObjectListViewController.m
//  Flipboard
//
//  Created by Ryan Olson on 5/28/14.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXObjectListViewController.h"
#import "IMLEXObjectExplorerFactory.h"
#import "IMLEXObjectExplorerViewController.h"
#import "IMLEXMutableListSection.h"
#import "IMLEXRuntimeUtility.h"
#import "IMLEXUtility.h"
#import "IMLEXHeapEnumerator.h"
#import "IMLEXObjectRef.h"
#import "NSString+IMLEX.h"
#import "NSObject+Reflection.h"
#import "IMLEXTableViewCell.h"
#import <malloc/malloc.h>


@interface IMLEXObjectListViewController ()
@property (nonatomic, copy) NSArray<IMLEXMutableListSection *> *sections;
@property (nonatomic, copy) NSArray<IMLEXMutableListSection *> *allSections;

@property (nonatomic, readonly) NSArray<IMLEXObjectRef *> *references;
@property (nonatomic, readonly) NSArray<NSPredicate *> *predicates;
@property (nonatomic, readonly) NSArray<NSString *> *sectionTitles;

@end

@implementation IMLEXObjectListViewController
@dynamic sections, allSections;

#pragma mark - Reference Grouping

+ (NSPredicate *)defaultPredicateForSection:(NSInteger)section {
    // These are the types of references that we typically don't care about.
    // We want this list of "object-ivar pairs" split into two sections.
    BOOL(^isObserver)(IMLEXObjectRef *, NSDictionary *) = ^BOOL(IMLEXObjectRef *ref, NSDictionary *bindings) {
        NSString *row = ref.reference;
        return [row isEqualToString:@"__NSObserver object"] ||
               [row isEqualToString:@"_CFXNotificationObjcObserverRegistration _object"];
    };

    /// These are common AutoLayout related references we also rarely care about.
    BOOL(^isConstraintRelated)(IMLEXObjectRef *, NSDictionary *) = ^BOOL(IMLEXObjectRef *ref, NSDictionary *bindings) {
        static NSSet *ignored = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            ignored = [NSSet setWithArray:@[
                @"NSLayoutConstraint _container",
                @"NSContentSizeLayoutConstraint _container",
                @"NSAutoresizingMaskLayoutConstraint _container",
                @"MASViewConstraint _installedView",
                @"MASLayoutConstraint _container",
                @"MASViewAttribute _view"
            ]];
        });

        NSString *row = ref.reference;
        return ([row hasPrefix:@"NSLayout"] && [row hasSuffix:@" _referenceItem"]) ||
               ([row hasPrefix:@"NSIS"] && [row hasSuffix:@" _delegate"])  ||
               ([row hasPrefix:@"_NSAutoresizingMask"] && [row hasSuffix:@" _referenceItem"]) ||
               [ignored containsObject:row];
    };

    BOOL(^isEssential)(IMLEXObjectRef *, NSDictionary *) = ^BOOL(IMLEXObjectRef *ref, NSDictionary *bindings) {
        return !(isObserver(ref, bindings) || isConstraintRelated(ref, bindings));
    };

    switch (section) {
        case 0: return [NSPredicate predicateWithBlock:isEssential];
        case 1: return [NSPredicate predicateWithBlock:isConstraintRelated];
        case 2: return [NSPredicate predicateWithBlock:isObserver];

        default: return nil;
    }
}

+ (NSArray<NSPredicate *> *)defaultPredicates {
    return @[[self defaultPredicateForSection:0],
             [self defaultPredicateForSection:1],
             [self defaultPredicateForSection:2]];
}

+ (NSArray<NSString *> *)defaultSectionTitles {
    return @[@"", @"AutoLayout", @"Trivial"];
}


#pragma mark - Initialization

- (id)initWithReferences:(NSArray<IMLEXObjectRef *> *)references {
    return [self initWithReferences:references predicates:nil sectionTitles:nil];
}

- (id)initWithReferences:(NSArray<IMLEXObjectRef *> *)references
              predicates:(NSArray<NSPredicate *> *)predicates
           sectionTitles:(NSArray<NSString *> *)sectionTitles {
    NSParameterAssert(predicates.count == sectionTitles.count);

    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _references = references;
        _predicates = predicates;
        _sectionTitles = sectionTitles;
    }

    return self;
}

+ (instancetype)instancesOfClassWithName:(NSString *)className {
    const char *classNameCString = className.UTF8String;
    NSMutableArray *instances = [NSMutableArray new];
    [IMLEXHeapEnumerator enumerateLiveObjectsUsingBlock:^(__unsafe_unretained id object, __unsafe_unretained Class actualClass) {
        if (strcmp(classNameCString, class_getName(actualClass)) == 0) {
            // Note: objects of certain classes crash when retain is called.
            // It is up to the user to avoid tapping into instance lists for these classes.
            // Ex. OS_dispatch_queue_specific_queue
            // In the future, we could provide some kind of warning for classes that are known to be problematic.
            if (malloc_size((__bridge const void *)(object)) > 0) {
                [instances addObject:object];
            }
        }
    }];
    
    NSArray<IMLEXObjectRef *> *references = [IMLEXObjectRef referencingAll:instances];
    IMLEXObjectListViewController *controller = [[self alloc] initWithReferences:references];
    controller.title = [NSString stringWithFormat:@"%@ (%lu)", className, (unsigned long)instances.count];
    return controller;
}

+ (instancetype)subclassesOfClassWithName:(NSString *)className {
    NSArray<Class> *classes = IMLEXGetAllSubclasses(NSClassFromString(className), NO);
    NSArray<IMLEXObjectRef *> *references = [IMLEXObjectRef referencingClasses:classes];
    IMLEXObjectListViewController *controller = [[self alloc] initWithReferences:references];
    controller.title = [NSString stringWithFormat:@"Subclasses of %@ (%lu)",
        className, (unsigned long)classes.count
    ];
    
    return controller;
}

+ (instancetype)objectsWithReferencesToObject:(id)object {
    static Class SwiftObjectClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SwiftObjectClass = NSClassFromString(@"SwiftObject");
        if (!SwiftObjectClass) {
            SwiftObjectClass = NSClassFromString(@"Swift._SwiftObject");
        }
    });
    
    NSMutableArray<IMLEXObjectRef *> *instances = [NSMutableArray new];
    [IMLEXHeapEnumerator enumerateLiveObjectsUsingBlock:^(__unsafe_unretained id tryObject, __unsafe_unretained Class actualClass) {
        // Get all the ivars on the object. Start with the class and and travel up the inheritance chain.
        // Once we find a match, record it and move on to the next object. There's no reason to find multiple matches within the same object.
        Class tryClass = actualClass;
        while (tryClass) {
            unsigned int ivarCount = 0;
            Ivar *ivars = class_copyIvarList(tryClass, &ivarCount);
            
            for (unsigned int ivarIndex = 0; ivarIndex < ivarCount; ivarIndex++) {
                Ivar ivar = ivars[ivarIndex];
                NSString *typeEncoding = @(ivar_getTypeEncoding(ivar) ?: "");
                
                if (typeEncoding.IMLEX_typeIsObjectOrClass) {
                    ptrdiff_t offset = ivar_getOffset(ivar);
                    uintptr_t *fieldPointer = (__bridge void *)tryObject + offset;
                    
                    if (*fieldPointer == (uintptr_t)(__bridge void *)object) {
                        NSString *ivarName = @(ivar_getName(ivar) ?: "???");
                        [instances addObject:[IMLEXObjectRef referencing:tryObject ivar:ivarName]];
                        return;
                    }
                }
            }
            
            tryClass = class_getSuperclass(tryClass);
        }
    }];

    NSArray<NSPredicate *> *predicates = [self defaultPredicates];
    NSArray<NSString *> *sectionTitles = [self defaultSectionTitles];
    IMLEXObjectListViewController *viewController = [[self alloc]
        initWithReferences:instances
        predicates:predicates
        sectionTitles:sectionTitles
    ];
    viewController.title = [NSString stringWithFormat:@"Referencing %@ %p",
        NSStringFromClass(object_getClass(object)), object
    ];
    return viewController;
}


#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showsSearchBar = YES;
}

- (NSArray<IMLEXMutableListSection *> *)makeSections {
    if (self.predicates.count) {
        return [self buildSections:self.sectionTitles predicates:self.predicates];
    } else {
        return @[[self makeSection:self.references title:nil]];
    }
}


#pragma mark - Private

- (NSArray *)buildSections:(NSArray<NSString *> *)titles predicates:(NSArray<NSPredicate *> *)predicates {
    NSParameterAssert(titles.count == predicates.count);
    NSParameterAssert(titles); NSParameterAssert(predicates);
    
    return [NSArray IMLEX_forEachUpTo:titles.count map:^id(NSUInteger i) {
        NSArray *rows = [self.references filteredArrayUsingPredicate:predicates[i]];
        return [self makeSection:rows title:titles[i]];
    }];
}

- (IMLEXMutableListSection *)makeSection:(NSArray *)rows title:(NSString *)title {
    IMLEXMutableListSection *section = [IMLEXMutableListSection list:rows
        cellConfiguration:^(IMLEXTableViewCell *cell, IMLEXObjectRef *ref, NSInteger row) {
            cell.textLabel.text = ref.reference;
            cell.detailTextLabel.text = ref.summary;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } filterMatcher:^BOOL(NSString *filterText, IMLEXObjectRef *ref) {
            if (ref.summary && [ref.summary localizedCaseInsensitiveContainsString:filterText]) {
                return YES;
            }
            
            return [ref.reference localizedCaseInsensitiveContainsString:filterText];
        }
    ];
    
    section.selectionHandler = ^(__kindof UIViewController *host, IMLEXObjectRef *ref) {
        [self.navigationController pushViewController:[
            IMLEXObjectExplorerFactory explorerViewControllerForObject:ref.object
        ] animated:YES];
    };

    section.customTitle = title;    
    return section;
}

@end
