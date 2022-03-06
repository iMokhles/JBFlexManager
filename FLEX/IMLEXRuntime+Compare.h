//
//  IMLEXRuntime+Compare.h
//  IMLEX
//
//  Created by Tanner Bennett on 8/28/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMLEXProperty.h"
#import "IMLEXIvar.h"
#import "IMLEXMethodBase.h"
#import "IMLEXProtocol.h"

@interface IMLEXProperty (Compare)
- (NSComparisonResult)compare:(IMLEXProperty *)other;
@end

@interface IMLEXIvar (Compare)
- (NSComparisonResult)compare:(IMLEXIvar *)other;
@end

@interface IMLEXMethodBase (Compare)
- (NSComparisonResult)compare:(IMLEXMethodBase *)other;
@end

@interface IMLEXProtocol (Compare)
- (NSComparisonResult)compare:(IMLEXProtocol *)other;
@end
