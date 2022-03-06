//
//  IMLEXMacros.h
//  IMLEX
//
//  Created by Tanner on 3/12/20.
//  Copyright © 2020 Flipboard. All rights reserved.
//

#ifndef IMLEXMacros_h
#define IMLEXMacros_h

// Used to prevent loading of pre-registered shortcuts and runtime categories in a test environment
#define IMLEX_EXIT_IF_TESTING() if (NSClassFromString(@"XCTest")) return;

/// Rounds down to the nearest "point" coordinate
NS_INLINE CGFloat IMLEXFloor(CGFloat x) {
    return floor(UIScreen.mainScreen.scale * (x)) / UIScreen.mainScreen.scale;
}

/// Returns the given number of points in pixels
NS_INLINE CGFloat IMLEXPointsToPixels(CGFloat points) {
    return points / UIScreen.mainScreen.scale;
}

/// Creates a CGRect with all members rounded down to the nearest "point" coordinate
NS_INLINE CGRect IMLEXRectMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height) {
    return CGRectMake(IMLEXFloor(x), IMLEXFloor(y), IMLEXFloor(width), IMLEXFloor(height));
}

/// Adjusts the origin of an existing rect
NS_INLINE CGRect IMLEXRectSetOrigin(CGRect r, CGPoint origin) {
    r.origin = origin; return r;
}

/// Adjusts the size of an existing rect
NS_INLINE CGRect IMLEXRectSetSize(CGRect r, CGSize size) {
    r.size = size; return r;
}

/// Adjusts the origin.x of an existing rect
NS_INLINE CGRect IMLEXRectSetX(CGRect r, CGFloat x) {
    r.origin.x = x; return r;
}

/// Adjusts the origin.y of an existing rect
NS_INLINE CGRect IMLEXRectSetY(CGRect r, CGFloat y) {
    r.origin.y = y ; return r;
}

/// Adjusts the size.width of an existing rect
NS_INLINE CGRect IMLEXRectSetWidth(CGRect r, CGFloat width) {
    r.size.width = width; return r;
}

/// Adjusts the size.height of an existing rect
NS_INLINE CGRect IMLEXRectSetHeight(CGRect r, CGFloat height) {
    r.size.height = height; return r;
}

#ifdef __IPHONE_13_0
#define IMLEX_AT_LEAST_IOS13_SDK (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
#else
#define IMLEX_AT_LEAST_IOS13_SDK NO
#endif

#define IMLEXPluralString(count, plural, singular) [NSString \
    stringWithFormat:@"%@ %@", @(count), (count == 1 ? singular : plural) \
]

#define IMLEXPluralFormatString(count, pluralFormat, singularFormat) [NSString \
    stringWithFormat:(count == 1 ? singularFormat : pluralFormat), @(count)  \
]

#endif /* IMLEXMacros_h */
