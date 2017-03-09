//
//  R2RRoute.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 4/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "R2RWalkDriveSegment.h"
#import "R2RTransitSegment.h"
#import "R2RFlightSegment.h"

@interface R2RRoute : NSObject

@property (strong, nonatomic) NSString *name;
@property (nonatomic) float distance;
@property (nonatomic) float duration;
@property (strong, nonatomic) R2RIndicativePrice *indicativePrice;
@property (strong, nonatomic) NSMutableArray *stops;
@property (strong, nonatomic) NSMutableArray *segments;

@end
