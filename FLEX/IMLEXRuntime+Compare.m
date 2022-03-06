//
//  IMLEXRuntime+Compare.m
//  IMLEX
//
//  Created by Tanner Bennett on 8/28/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXRuntime+Compare.h"

@implementation IMLEXProperty (Compare)

- (NSComparisonResult)compare:(IMLEXProperty *)other {
    NSComparisonResult r = [self.name caseInsensitiveCompare:other.name];
    if (r == NSOrderedSame) {
        // TODO make sure empty image name sorts above an image name
        return [self.imageName ?: @"" compare:other.imageName];
    }

    return r;
}

@end

@implementation IMLEXIvar (Compare)

- (NSComparisonResult)compare:(IMLEXIvar *)other {
    return [self.name caseInsensitiveCompare:other.name];
}

@end

@implementation IMLEXMethodBase (Compare)

- (NSComparisonResult)compare:(IMLEXMethodBase *)other {
    return [self.name caseInsensitiveCompare:other.name];
}

@end

@implementation IMLEXProtocol (Compare)

- (NSComparisonResult)compare:(IMLEXProtocol *)other {
    return [self.name caseInsensitiveCompare:other.name];
}

@end
