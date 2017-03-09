//
//  R2RFlightItinerary.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 4/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "R2RFlightLeg.h"
#import "R2RFlightTicketSet.h"

@interface R2RFlightItinerary : NSObject

@property (strong, nonatomic) NSMutableArray *legs;
@property (strong, nonatomic) NSMutableArray *ticketSets;

@end
