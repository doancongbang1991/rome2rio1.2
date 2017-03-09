//
//  R2RFlightLeg.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 4/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "R2RFlightHop.h"

@interface R2RFlightLeg : NSObject

@property (strong, nonatomic) NSMutableArray *hops;
@property (nonatomic) NSInteger days;

@end
