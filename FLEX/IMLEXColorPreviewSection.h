//
//  IMLEXColorPreviewSection.h
//  IMLEX
//
//  Created by Tanner Bennett on 12/12/19.
//  Copyright © 2019 Flipboard. All rights reserved.
//

#import "IMLEXSingleRowSection.h"
#import "IMLEXObjectInfoSection.h"

@interface IMLEXColorPreviewSection : IMLEXSingleRowSection <IMLEXObjectInfoSection>

+ (instancetype)forObject:(UIColor *)color;

@end
