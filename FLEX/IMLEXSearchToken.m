//
//  IMLEXSearchToken.m
//  IMLEX
//
//  Created by Tanner on 3/22/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "IMLEXSearchToken.h"

@interface IMLEXSearchToken () {
    NSString *IMLEX_description;
}
@end

@implementation IMLEXSearchToken

+ (instancetype)any {
    static IMLEXSearchToken *any = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        any = [self string:nil options:TBWildcardOptionsAny];
    });

    return any;
}

+ (instancetype)string:(NSString *)string options:(TBWildcardOptions)options {
    IMLEXSearchToken *token  = [self new];
    token->_string  = string;
    token->_options = options;
    return token;
}

- (BOOL)isAbsolute {
    return _options == TBWildcardOptionsNone;
}

- (BOOL)isAny {
    return _options == TBWildcardOptionsAny;
}

- (BOOL)isEmpty {
    return self.isAny && self.string.length == 0;
}

- (NSString *)description {
    if (IMLEX_description) {
        return IMLEX_description;
    }

    switch (_options) {
        case TBWildcardOptionsNone:
            IMLEX_description = _string;
            break;
        case TBWildcardOptionsAny:
            IMLEX_description = @"*";
            break;
        default: {
            NSMutableString *desc = [NSMutableString new];
            if (_options & TBWildcardOptionsPrefix) {
                [desc appendString:@"*"];
            }
            [desc appendString:_string];
            if (_options & TBWildcardOptionsSuffix) {
                [desc appendString:@"*"];
            }
            IMLEX_description = desc;
        }
    }

    return IMLEX_description;
}

- (NSUInteger)hash {
    return self.description.hash;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[IMLEXSearchToken class]]) {
        IMLEXSearchToken *token = object;
        return [_string isEqualToString:token->_string] && _options == token->_options;
    }

    return NO;
}

@end
