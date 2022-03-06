//
//  IMLEXRuntimeKeyPathTokenizer.h
//  IMLEX
//
//  Created by Tanner on 3/22/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "IMLEXRuntimeKeyPath.h"

@interface IMLEXRuntimeKeyPathTokenizer : NSObject

+ (NSUInteger)tokenCountOfString:(NSString *)userInput;
+ (IMLEXRuntimeKeyPath *)tokenizeString:(NSString *)userInput;

+ (BOOL)allowedInKeyPath:(NSString *)text;

@end
