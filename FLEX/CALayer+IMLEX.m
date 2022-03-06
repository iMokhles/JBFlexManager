//
//  CALayer+IMLEX.m
//  IMLEX
//
//  Created by Tanner on 2/28/20.
//  Copyright © 2020 Flipboard. All rights reserved.
//

#import "CALayer+IMLEX.h"

@interface CALayer (Private)
@property (nonatomic) BOOL continuousCorners;
@end

@implementation CALayer (IMLEX)

static BOOL respondsToContinuousCorners = NO;

+ (void)load {
    respondsToContinuousCorners = [CALayer
        instancesRespondToSelector:@selector(setContinuousCorners:)
    ];
}

- (BOOL)IMLEX_continuousCorners {
    if (respondsToContinuousCorners) {
        return self.continuousCorners;
    }
    
    return NO;
}

- (void)setIMLEX_continuousCorners:(BOOL)enabled {
    if (respondsToContinuousCorners) {
        if (@available(iOS 13, *)) {
            self.cornerCurve = kCACornerCurveContinuous;
        } else {
            self.continuousCorners = enabled;
//            self.masksToBounds = NO;
    //        self.allowsEdgeAntialiasing = YES;
    //        self.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerTopEdge | kCALayerBottomEdge;
        }
    }
}

@end
