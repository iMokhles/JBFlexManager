//
//  IMLEXMetadataSection.m
//  IMLEX
//
//  Created by Tanner Bennett on 9/19/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXMetadataSection.h"
#import "IMLEXTableView.h"
#import "IMLEXTableViewCell.h"
#import "IMLEXObjectExplorerFactory.h"
#import "IMLEXFieldEditorViewController.h"
#import "IMLEXMethodCallingViewController.h"
#import "IMLEXIvar.h"
#import "NSArray+Functional.h"
#import "IMLEXRuntime+UIKitHelpers.h"

@interface IMLEXMetadataSection ()
@property (nonatomic, readonly) IMLEXObjectExplorer *explorer;
/// Filtered
@property (nonatomic, copy) NSArray<id<IMLEXRuntimeMetadata>> *metadata;
/// Unfiltered
@property (nonatomic, copy) NSArray<id<IMLEXRuntimeMetadata>> *allMetadata;
@end

@implementation IMLEXMetadataSection

#pragma mark - Initialization

+ (instancetype)explorer:(IMLEXObjectExplorer *)explorer kind:(IMLEXMetadataKind)metadataKind {
    return [[self alloc] initWithExplorer:explorer kind:metadataKind];
}

- (id)initWithExplorer:(IMLEXObjectExplorer *)explorer kind:(IMLEXMetadataKind)metadataKind {
    self = [super init];
    if (self) {
        _explorer = explorer;
        _metadataKind = metadataKind;

        [self reloadData];
    }

    return self;
}

#pragma mark - Private

- (NSString *)titleWithBaseName:(NSString *)baseName {
    unsigned long totalCount = self.allMetadata.count;
    unsigned long filteredCount = self.metadata.count;

    if (totalCount == filteredCount) {
        return [baseName stringByAppendingFormat:@" (%lu)", totalCount];
    } else {
        return [baseName stringByAppendingFormat:@" (%lu of %lu)", filteredCount, totalCount];
    }
}

- (UITableViewCellAccessoryType)accessoryTypeForRow:(NSInteger)row {
    return [self.metadata[row] suggestedAccessoryTypeWithTarget:self.explorer.object];
}

#pragma mark - Public

- (void)setExcludedMetadata:(NSSet<NSString *> *)excludedMetadata {
    _excludedMetadata = excludedMetadata;
    [self reloadData];
}

#pragma mark - Overrides

- (NSString *)titleForRow:(NSInteger)row {
    return [self.metadata[row] description];
}

- (NSString *)subtitleForRow:(NSInteger)row {
    return [self.metadata[row] previewWithTarget:self.explorer.object];
}

- (NSString *)title {
    switch (self.metadataKind) {
        case IMLEXMetadataKindProperties:
            return [self titleWithBaseName:@"Properties"];
        case IMLEXMetadataKindClassProperties:
            return [self titleWithBaseName:@"Class Properties"];
        case IMLEXMetadataKindIvars:
            return [self titleWithBaseName:@"Ivars"];
        case IMLEXMetadataKindMethods:
            return [self titleWithBaseName:@"Methods"];
        case IMLEXMetadataKindClassMethods:
            return [self titleWithBaseName:@"Class Methods"];
        case IMLEXMetadataKindClassHierarchy:
            return [self titleWithBaseName:@"Class Hierarchy"];
        case IMLEXMetadataKindProtocols:
            return [self titleWithBaseName:@"Protocols"];
        case IMLEXMetadataKindOther:
            return @"Miscellaneous";
    }
}

- (NSInteger)numberOfRows {
    return self.metadata.count;
}

- (void)setFilterText:(NSString *)filterText {
    super.filterText = filterText;

    if (!self.filterText.length) {
        self.metadata = self.allMetadata;
    } else {
        self.metadata = [self.allMetadata IMLEX_filtered:^BOOL(IMLEXProperty *obj, NSUInteger idx) {
            return [obj.description localizedCaseInsensitiveContainsString:self.filterText];
        }];
    }
}

- (void)reloadData {
    switch (self.metadataKind) {
        case IMLEXMetadataKindProperties:
            self.allMetadata = self.explorer.properties;
            break;
        case IMLEXMetadataKindClassProperties:
            self.allMetadata = self.explorer.classProperties;
            break;
        case IMLEXMetadataKindIvars:
            self.allMetadata = self.explorer.ivars;
            break;
        case IMLEXMetadataKindMethods:
            self.allMetadata = self.explorer.methods;
            break;
        case IMLEXMetadataKindClassMethods:
            self.allMetadata = self.explorer.classMethods;
            break;
        case IMLEXMetadataKindProtocols:
            self.allMetadata = self.explorer.conformedProtocols;
            break;
        case IMLEXMetadataKindClassHierarchy:
            self.allMetadata = self.explorer.classHierarchy;
            break;
        case IMLEXMetadataKindOther:
            self.allMetadata = @[self.explorer.instanceSize, self.explorer.imageName];
            break;
    }

    // Remove excluded metadata
    if (self.excludedMetadata.count) {
        id filterBlock = ^BOOL(id<IMLEXRuntimeMetadata> obj, NSUInteger idx) {
            return ![self.excludedMetadata containsObject:obj.name];
        };

        // Filter exclusions and sort
        self.allMetadata = [[self.allMetadata IMLEX_filtered:filterBlock]
            sortedArrayUsingSelector:@selector(compare:)
        ];
    }

    // Re-filter data
    self.filterText = self.filterText;
}

- (BOOL)canSelectRow:(NSInteger)row {
    UITableViewCellAccessoryType accessory = [self accessoryTypeForRow:row];
    return accessory == UITableViewCellAccessoryDisclosureIndicator ||
        accessory == UITableViewCellAccessoryDetailDisclosureButton;
}

- (NSString *)reuseIdentifierForRow:(NSInteger)row {
    return [self.metadata[row] reuseIdentifierWithTarget:self.explorer.object] ?: kIMLEXCodeFontCell;
}

- (UIViewController *)viewControllerToPushForRow:(NSInteger)row {
    return [self.metadata[row] viewerWithTarget:self.explorer.object];
}

- (void (^)(__kindof UIViewController *))didPressInfoButtonAction:(NSInteger)row {
    return ^(UIViewController *host) {
        [host.navigationController pushViewController:[self editorForRow:row] animated:YES];
    };
}

- (UIViewController *)editorForRow:(NSInteger)row {
    return [self.metadata[row] editorWithTarget:self.explorer.object];
}

- (void)configureCell:(__kindof IMLEXTableViewCell *)cell forRow:(NSInteger)row {
    cell.titleLabel.text = [self titleForRow:row];
    cell.subtitleLabel.text = [self subtitleForRow:row];
    cell.accessoryType = [self accessoryTypeForRow:row];
}

#if IMLEX_AT_LEAST_IOS13_SDK

- (NSString *)menuSubtitleForRow:(NSInteger)row {
    return [self.metadata[row] contextualSubtitleWithTarget:self.explorer.object];
}

- (NSArray<UIMenuElement *> *)menuItemsForRow:(NSInteger)row sender:(UIViewController *)sender {
    NSArray<UIMenuElement *> *existingItems = [super menuItemsForRow:row sender:sender];
    
    // These two metadata kinds don't any of the additional options below
    switch (self.metadataKind) {
        case IMLEXMetadataKindClassHierarchy:
        case IMLEXMetadataKindOther:
            return existingItems;
            
        default: break;
    }
    
    id<IMLEXRuntimeMetadata> metadata = self.metadata[row];
    NSMutableArray<UIMenuElement *> *menuItems = [NSMutableArray new];
    
    [menuItems addObject:[UIAction
        actionWithTitle:@"Explore Metadata"
        image:nil
        identifier:nil
        handler:^(__kindof UIAction *action) {
            [sender.navigationController pushViewController:[IMLEXObjectExplorerFactory
                explorerViewControllerForObject:metadata
            ] animated:YES];
        }
    ]];
    [menuItems addObjectsFromArray:[metadata
        additionalActionsWithTarget:self.explorer.object sender:sender
    ]];
    [menuItems addObjectsFromArray:existingItems];
    
    return menuItems.copy;
}

- (NSArray<NSString *> *)copyMenuItemsForRow:(NSInteger)row {
    return [self.metadata[row] copiableMetadataWithTarget:self.explorer.object];
}

#endif

@end
