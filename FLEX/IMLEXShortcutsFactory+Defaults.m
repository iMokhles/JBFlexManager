//
//  IMLEXShortcutsFactory+Defaults.m
//  IMLEX
//
//  Created by Tanner Bennett on 8/29/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXShortcutsFactory+Defaults.h"
#import "IMLEXShortcut.h"
#import "IMLEXRuntimeUtility.h"
#import "NSObject+Reflection.h"

#pragma mark - Views

@implementation IMLEXShortcutsFactory (Views)

+ (void)load { IMLEX_EXIT_IF_TESTING()
    // A quirk of UIView and some other classes: a lot of the `@property`s are
    // not actually properties from the perspective of the runtime.
    //
    // We add these properties to the class at runtime if they haven't been added yet.
    // This way, we can use our property editor to access and change them.
    // The property attributes match the declared attributes in their headers.

    // UIView, public
    Class UIView_ = UIView.class;
    IMLEXRuntimeUtilityTryAddNonatomicProperty(2, frame, UIView_, CGRect);
    IMLEXRuntimeUtilityTryAddNonatomicProperty(2, alpha, UIView_, CGFloat);
    IMLEXRuntimeUtilityTryAddNonatomicProperty(2, clipsToBounds, UIView_, BOOL);
    IMLEXRuntimeUtilityTryAddNonatomicProperty(2, opaque, UIView_, BOOL, PropertyKeyGetter(isOpaque));
    IMLEXRuntimeUtilityTryAddNonatomicProperty(2, hidden, UIView_, BOOL, PropertyKeyGetter(isHidden));
    IMLEXRuntimeUtilityTryAddObjectProperty(2, backgroundColor, UIView_, UIColor, PropertyKey(Copy));
    IMLEXRuntimeUtilityTryAddObjectProperty(6, constraints, UIView_, NSArray, PropertyKey(ReadOnly));
    IMLEXRuntimeUtilityTryAddObjectProperty(2, subviews, UIView_, NSArray, PropertyKey(ReadOnly));
    IMLEXRuntimeUtilityTryAddObjectProperty(2, superview, UIView_, UIView, PropertyKey(ReadOnly));

    // UIButton, private
    IMLEXRuntimeUtilityTryAddObjectProperty(2, font, UIButton.class, UIFont, PropertyKey(ReadOnly));
    
    // Only available since iOS 3.2, but we never supported iOS 3, so who cares
    NSArray *ivars = @[@"_gestureRecognizers"];
    NSArray *methods = @[@"sizeToFit", @"setNeedsLayout", @"removeFromSuperview"];

    // UIView
    self.append.ivars(ivars).methods(methods).properties(@[
        @"frame", @"bounds", @"center", @"transform",
        @"backgroundColor", @"alpha", @"opaque", @"hidden",
        @"clipsToBounds", @"userInteractionEnabled", @"layer",
        @"superview", @"subviews"
    ]).forClass(UIView.class);

    // UILabel
    self.append.ivars(ivars).methods(methods).properties(@[
        @"text", @"attributedText", @"font", @"frame",
        @"textColor", @"textAlignment", @"numberOfLines",
        @"lineBreakMode", @"enabled", @"backgroundColor",
        @"alpha", @"hidden", @"preferredMaxLayoutWidth",
        @"superview", @"subviews"
    ]).forClass(UILabel.class);

    // UIWindow
    self.append.ivars(ivars).properties(@[
        @"rootViewController", @"windowLevel", @"keyWindow",
        @"frame", @"bounds", @"center", @"transform",
        @"backgroundColor", @"alpha", @"opaque", @"hidden",
        @"clipsToBounds", @"userInteractionEnabled", @"layer",
        @"subviews"
    ]).forClass(UIWindow.class);

    if (@available(iOS 13, *)) {
        self.append.properties(@[@"windowScene"]).forClass(UIWindow.class);
    }

    ivars = @[@"_targetActions", @"_gestureRecognizers"];
    
    // Property was added in iOS 10 but we want it on iOS 9 too
    IMLEXRuntimeUtilityTryAddObjectProperty(9, allTargets, UIControl.class, NSArray, PropertyKey(ReadOnly));

    // UIControl
    self.append.ivars(ivars).methods(methods).properties(@[
        @"enabled", @"allTargets", @"frame",
        @"backgroundColor", @"hidden", @"clipsToBounds",
        @"userInteractionEnabled", @"superview", @"subviews"
    ]).forClass(UIControl.class);

    // UIButton
    self.append.ivars(ivars).properties(@[
        @"titleLabel", @"font", @"imageView", @"tintColor",
        @"currentTitle", @"currentImage", @"enabled", @"frame",
        @"superview", @"subviews"
    ]).forClass(UIButton.class);
}

@end


#pragma mark - View Controllers

@implementation IMLEXShortcutsFactory (ViewControllers)

+ (void)load { IMLEX_EXIT_IF_TESTING()
    // toolbarItems is not really a property, make it one 
    IMLEXRuntimeUtilityTryAddObjectProperty(3, toolbarItems, UIViewController.class, NSArray);
    
    // UIViewController
    self.append
        .properties(@[
            @"viewIfLoaded", @"title", @"navigationItem", @"toolbarItems", @"tabBarItem",
            @"childViewControllers", @"navigationController", @"tabBarController", @"splitViewController",
            @"parentViewController", @"presentedViewController", @"presentingViewController",
        ]).methods(@[@"view"]).forClass(UIViewController.class);
}

@end


#pragma mark - UIImage

@implementation IMLEXShortcutsFactory (UIImage)

+ (void)load { IMLEX_EXIT_IF_TESTING()
    self.append.methods(@[
        @"CGImage", @"CIImage"
    ]).properties(@[
        @"scale", @"size", @"capInsets",
        @"alignmentRectInsets", @"duration", @"images"
    ]).forClass(UIImage.class);

    if (@available(iOS 13, *)) {
        self.append.properties(@[@"symbolImage"]);
    }
}

@end


#pragma mark - NSBundle

@implementation IMLEXShortcutsFactory (NSBundle)

+ (void)load { IMLEX_EXIT_IF_TESTING()
    self.append.properties(@[
        @"bundleIdentifier", @"principalClass",
        @"infoDictionary", @"bundlePath",
        @"executablePath", @"loaded"
    ]).forClass(NSBundle.class);
}

@end


#pragma mark - Classes

@implementation IMLEXShortcutsFactory (Classes)

+ (void)load { IMLEX_EXIT_IF_TESTING()
    self.append.classMethods(@[@"new", @"alloc"]).forClass(NSObject.IMLEX_metaclass);
}

@end


#pragma mark - Activities

@implementation IMLEXShortcutsFactory (Activities)

+ (void)load { IMLEX_EXIT_IF_TESTING()
    // Property was added in iOS 10 but we want it on iOS 9 too
    IMLEXRuntimeUtilityTryAddNonatomicProperty(9, item, UIActivityItemProvider.class, id, PropertyKey(ReadOnly));
    
    self.append.properties(@[
        @"item", @"placeholderItem", @"activityType"
    ]).forClass(UIActivityItemProvider.class);

    self.append.properties(@[
        @"activityItems", @"applicationActivities", @"excludedActivityTypes", @"completionHandler"
    ]).forClass(UIActivityViewController.class);
}

@end


#pragma mark - Blocks

@implementation IMLEXShortcutsFactory (Blocks)

+ (void)load { IMLEX_EXIT_IF_TESTING()
    self.append.methods(@[@"invoke"]).forClass(NSClassFromString(@"NSBlock"));
}

@end

#pragma mark - Foundation

@implementation IMLEXShortcutsFactory (Foundation)

+ (void)load { IMLEX_EXIT_IF_TESTING()
    self.append.properties(@[
        @"configuration", @"delegate", @"delegateQueue", @"sessionDescription",
    ]).methods(@[
        @"dataTaskWithURL:", @"finishTasksAndInvalidate", @"invalidateAndCancel",
    ]).forClass(NSURLSession.class);
    
    self.append.methods(@[
        @"cachedResponseForRequest:", @"storeCachedResponse:forRequest:",
        @"storeCachedResponse:forDataTask:", @"removeCachedResponseForRequest:",
        @"removeCachedResponseForDataTask:", @"removeCachedResponsesSinceDate:",
        @"removeAllCachedResponses",
    ]).forClass(NSURLCache.class);
    
    
    self.append.methods(@[
        @"postNotification:", @"postNotificationName:object:userInfo:",
        @"addObserver:selector:name:object:", @"removeObserver:",
        @"removeObserver:name:object:",
    ]).forClass(NSNotificationCenter.class);
    
    // NSTimeZone class properties aren't real properties
    IMLEXRuntimeUtilityTryAddObjectProperty(2, localTimeZone, NSTimeZone.IMLEX_metaclass, NSTimeZone);
    IMLEXRuntimeUtilityTryAddObjectProperty(2, systemTimeZone, NSTimeZone.IMLEX_metaclass, NSTimeZone);
    IMLEXRuntimeUtilityTryAddObjectProperty(2, defaultTimeZone, NSTimeZone.IMLEX_metaclass, NSTimeZone);
    IMLEXRuntimeUtilityTryAddObjectProperty(2, knownTimeZoneNames, NSTimeZone.IMLEX_metaclass, NSArray);
    IMLEXRuntimeUtilityTryAddObjectProperty(2, abbreviationDictionary, NSTimeZone.IMLEX_metaclass, NSDictionary);
    
    self.append.classMethods(@[
        @"timeZoneWithName:", @"timeZoneWithAbbreviation:", @"timeZoneForSecondsFromGMT:", @"", @"", @"", 
    ]).forClass(NSTimeZone.IMLEX_metaclass);
    
    self.append.classProperties(@[
        @"defaultTimeZone", @"systemTimeZone", @"localTimeZone"
    ]).forClass(NSTimeZone.class);
    
    
//    self.append.<#type#>(@[@"<#value#>"]).forClass(NSURLSession.class);
//    
//    
//    self.append.<#type#>(@[@"<#value#>"]).forClass(NSURLSession.class);
//    
//    
//    self.append.<#type#>(@[@"<#value#>"]).forClass(NSURLSession.class);
//    
//    
//    self.append.<#type#>(@[@"<#value#>"]).forClass(NSURLSession.class);
//    
//    
//    self.append.<#type#>(@[@"<#value#>"]).forClass(NSURLSession.class);
//    
//    
//    self.append.<#type#>(@[@"<#value#>"]).forClass(NSURLSession.class);
}

@end
