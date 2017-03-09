//
//  R2RTransitLeg.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 4/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "R2RTransitHop.h"
#include "R2RTransitLine.h"

@interface R2RTransitLeg : NSObject

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSMutableArray *hops;

@end
