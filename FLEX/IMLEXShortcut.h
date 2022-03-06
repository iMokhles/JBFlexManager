//
//  IMLEXShortcut.h
//  IMLEX
//
//  Created by Tanner Bennett on 12/10/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Represents a row in a shortcut section.
///
/// The purpsoe of this protocol is to allow delegating a small
/// subset of the responsibilities of a \c IMLEXShortcutsSection
/// to another object, for a single arbitrary row.
///
/// It is useful to make your own shortcuts to append/prepend
/// them to the existing list of shortcuts for a class.
@protocol IMLEXShortcut <NSObject>

- (nonnull  NSString *)titleWith:(id)object;
- (nullable NSString *)subtitleWith:(id)object;
- (nullable void (^)(UIViewController *host))didSelectActionWith:(id)object;
/// Called when the row is selected
- (nullable UIViewController *)viewerWith:(id)object;
/// Basically, whether or not to show a detail disclosure indicator
- (UITableViewCellAccessoryType)accessoryTypeWith:(id)object;
/// If nil is returned, the default reuse identifier is used
- (nullable NSString *)customReuseIdentifierWith:(id)object;

@optional
/// Called when the (i) button is pressed if the accessory type includes it
- (UIViewController *)editorWith:(id)object;

@end


/// Provides default behavior for IMLEX metadata objects. Also works in a limited way with strings.
/// Used internally. If you wish to use this object, only pass in \c IMLEX* metadata objects.
@interface IMLEXShortcut : NSObject <IMLEXShortcut>

/// @param item An \c NSString or \c IMLEX* metadata object.
/// @note You may also pass a \c IMLEXShortcut conforming object,
/// and that object will be returned instead.
+ (id<IMLEXShortcut>)shortcutFor:(id)item;

@end


/// Provides a quick and dirty implementation of the \c IMLEXShortcut protocol,
/// allowing you to specify a static title and dynamic atttributes for everything else.
/// The object passed into each block is the object passed to each \c IMLEXShortcut method.
///
/// Does not support the \c -editorWith: method.
@interface IMLEXActionShortcut : NSObject <IMLEXShortcut>

+ (instancetype)title:(NSString *)title
             subtitle:(nullable NSString *(^)(id object))subtitleFuture
               viewer:(nullable UIViewController *(^)(id object))viewerFuture
        accessoryType:(nullable UITableViewCellAccessoryType(^)(id object))accessoryTypeFuture;

+ (instancetype)title:(NSString *)title
             subtitle:(nullable NSString *(^)(id object))subtitleFuture
     selectionHandler:(nullable void (^)(UIViewController *host, id object))tapAction
        accessoryType:(nullable UITableViewCellAccessoryType(^)(id object))accessoryTypeFuture;

@end

NS_ASSUME_NONNULL_END
