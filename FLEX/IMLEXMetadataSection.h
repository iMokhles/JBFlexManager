//
//  IMLEXMetadataSection.h
//  IMLEX
//
//  Created by Tanner Bennett on 9/19/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXTableViewSection.h"
#import "IMLEXObjectExplorer.h"

typedef NS_ENUM(NSUInteger, IMLEXMetadataKind) {
    IMLEXMetadataKindProperties = 1,
    IMLEXMetadataKindClassProperties,
    IMLEXMetadataKindIvars,
    IMLEXMetadataKindMethods,
    IMLEXMetadataKindClassMethods,
    IMLEXMetadataKindClassHierarchy,
    IMLEXMetadataKindProtocols,
    IMLEXMetadataKindOther
};

/// This section is used for displaying ObjC runtime metadata
/// about a class or object, such as listing methods, properties, etc.
@interface IMLEXMetadataSection : IMLEXTableViewSection

+ (instancetype)explorer:(IMLEXObjectExplorer *)explorer kind:(IMLEXMetadataKind)metadataKind;

@property (nonatomic, readonly) IMLEXMetadataKind metadataKind;

/// The names of metadata to exclude. Useful if you wish to group specific
/// properties or methods together in their own section outside of this one.
///
/// Setting this property calls \c reloadData on this section.
@property (nonatomic) NSSet<NSString *> *excludedMetadata;

@end
