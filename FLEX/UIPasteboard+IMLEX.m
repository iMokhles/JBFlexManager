//
//  UIPasteboard+IMLEX.m
//  IMLEX
//
//  Created by Tanner Bennett on 12/9/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "UIPasteboard+IMLEX.h"

@implementation UIPasteboard (IMLEX)

- (void)IMLEX_copy:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        UIPasteboard.generalPasteboard.string = object;
    } else if([object isKindOfClass:[NSData class]]) {
        [UIPasteboard.generalPasteboard setData:object forPasteboardType:@"public.data"];
    } else if ([object isKindOfClass:[NSNumber class]]) {
        UIPasteboard.generalPasteboard.string = [object stringValue];
    }

    [NSException raise:NSInternalInconsistencyException
                format:@"Tried to copy unsupported type: %@", [object class]];
}

@end
