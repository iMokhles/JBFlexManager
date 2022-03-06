//
//  IMLEXShortcut.m
//  IMLEX
//
//  Created by Tanner Bennett on 12/10/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXShortcut.h"
#import "IMLEXProperty.h"
#import "IMLEXPropertyAttributes.h"
#import "IMLEXIvar.h"
#import "IMLEXMethod.h"
#import "IMLEXRuntime+UIKitHelpers.h"
#import "IMLEXObjectExplorerFactory.h"
#import "IMLEXFieldEditorViewController.h"
#import "IMLEXMethodCallingViewController.h"
#import "IMLEXMetadataSection.h"
#import "IMLEXTableView.h"


#pragma mark - IMLEXShortcut

@interface IMLEXShortcut () {
    id _item;
}

@property (nonatomic, readonly) IMLEXMetadataKind metadataKind;
@property (nonatomic, readonly) IMLEXProperty *property;
@property (nonatomic, readonly) IMLEXMethod *method;
@property (nonatomic, readonly) IMLEXIvar *ivar;
@property (nonatomic, readonly) id<IMLEXRuntimeMetadata> metadata;
@end

@implementation IMLEXShortcut

+ (id<IMLEXShortcut>)shortcutFor:(id)item {
    if ([item conformsToProtocol:@protocol(IMLEXShortcut)]) {
        return item;
    }
    
    IMLEXShortcut *shortcut = [self new];
    shortcut->_item = item;

    if ([item isKindOfClass:[IMLEXProperty class]]) {
        if (shortcut.property.isClassProperty) {
            shortcut->_metadataKind =  IMLEXMetadataKindClassProperties;
        } else {
            shortcut->_metadataKind =  IMLEXMetadataKindProperties;
        }
    }
    if ([item isKindOfClass:[IMLEXIvar class]]) {
        shortcut->_metadataKind = IMLEXMetadataKindIvars;
    }
    if ([item isKindOfClass:[IMLEXMethod class]]) {
        // We don't care if it's a class method or not
        shortcut->_metadataKind = IMLEXMetadataKindMethods;
    }

    return shortcut;
}

- (id)propertyOrIvarValue:(id)object {
    return [self.metadata currentValueWithTarget:object];
}

- (NSString *)titleWith:(id)object {
    switch (self.metadataKind) {
        case IMLEXMetadataKindClassProperties:
        case IMLEXMetadataKindProperties:
            // Since we're outside of the "properties" section, prepend @property for clarity.
            return [@"@property " stringByAppendingString:[_item description]];

        default:
            return [_item description];
    }

    NSAssert(
        [_item isKindOfClass:[NSString class]],
        @"Unexpected type: %@", [_item class]
    );

    return _item;
}

- (NSString *)subtitleWith:(id)object {
    if (self.metadataKind) {
        return [self.metadata previewWithTarget:object] ?: @"nil";
    }

    // Item is probably a string; must return empty string since
    // these will be gathered into an array. If the object is a
    // just a string, it doesn't get a subtitle.
    return @"";
}

- (void (^)(UIViewController *))didSelectActionWith:(id)object { 
    return nil;
}

- (UIViewController *)viewerWith:(id)object {
    NSAssert(self.metadataKind, @"Static titles cannot be viewed");
    return [self.metadata viewerWithTarget:object];
}

- (UIViewController *)editorWith:(id)object {
    NSAssert(self.metadataKind, @"Static titles cannot be edited");
    return [self.metadata editorWithTarget:object];
}

- (UITableViewCellAccessoryType)accessoryTypeWith:(id)object {
    if (self.metadataKind) {
        return [self.metadata suggestedAccessoryTypeWithTarget:object];
    }

    return UITableViewCellAccessoryNone;
}

- (NSString *)customReuseIdentifierWith:(id)object {
    if (self.metadataKind) {
        return kIMLEXCodeFontCell;
    }

    return kIMLEXMultilineCell;
}

#pragma mark - Helpers

- (IMLEXProperty *)property { return _item; }
- (IMLEXMethodBase *)method { return _item; }
- (IMLEXIvar *)ivar { return _item; }
- (id<IMLEXRuntimeMetadata>)metadata { return _item; }

@end


#pragma mark - IMLEXActionShortcut

@interface IMLEXActionShortcut ()
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *(^subtitleFuture)(id);
@property (nonatomic, readonly) UIViewController *(^viewerFuture)(id);
@property (nonatomic, readonly) void (^selectionHandler)(UIViewController *, id);
@property (nonatomic, readonly) UITableViewCellAccessoryType (^accessoryTypeFuture)(id);
@end

@implementation IMLEXActionShortcut

+ (instancetype)title:(NSString *)title
             subtitle:(NSString *(^)(id))subtitle
               viewer:(UIViewController *(^)(id))viewer
        accessoryType:(UITableViewCellAccessoryType (^)(id))type {
    return [[self alloc] initWithTitle:title subtitle:subtitle viewer:viewer selectionHandler:nil accessoryType:type];
}

+ (instancetype)title:(NSString *)title
             subtitle:(NSString * (^)(id))subtitle
     selectionHandler:(void (^)(UIViewController *, id))tapAction
        accessoryType:(UITableViewCellAccessoryType (^)(id))type {
    return [[self alloc] initWithTitle:title subtitle:subtitle viewer:nil selectionHandler:tapAction accessoryType:type];
}

- (id)initWithTitle:(NSString *)title
           subtitle:(id)subtitleFuture
             viewer:(id)viewerFuture
   selectionHandler:(id)tapAction
      accessoryType:(id)accessoryTypeFuture {
    NSParameterAssert(title.length);

    self = [super init];
    if (self) {
        id nilBlock = ^id (id obj) { return nil; };
        
        _title = title;
        _subtitleFuture = subtitleFuture ?: nilBlock;
        _viewerFuture = viewerFuture ?: nilBlock;
        _selectionHandler = tapAction;
        _accessoryTypeFuture = accessoryTypeFuture ?: nilBlock;
    }

    return self;
}

- (NSString *)titleWith:(id)object {
    return self.title;
}

- (NSString *)subtitleWith:(id)object {
    return self.subtitleFuture(object);
}

- (void (^)(UIViewController *))didSelectActionWith:(id)object {
    if (self.selectionHandler) {
        return ^(UIViewController *host) {
            self.selectionHandler(host, object);
        };
    }
    
    return nil;
}

- (UIViewController *)viewerWith:(id)object {
    return self.viewerFuture(object);
}

- (UITableViewCellAccessoryType)accessoryTypeWith:(id)object {
    return self.accessoryTypeFuture(object);
}

- (NSString *)customReuseIdentifierWith:(id)object {
    if (!self.subtitleFuture(object)) {
        // The text is more centered with this style if there is no subtitle
        return kIMLEXDefaultCell;
    }

    return nil;
}

@end
