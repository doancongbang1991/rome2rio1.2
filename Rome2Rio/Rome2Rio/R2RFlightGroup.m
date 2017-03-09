//
//  R2RFlightGroup.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 9/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RFlightGroup.h"

@implementation R2RFlightGroup

@synthesize flights, hops, name;

-(id) initWithHops: (NSInteger) initHops
{
    self = [super init];
    if (self != nil)
    {
        self.flights = [[NSMutableArray alloc] init];
        self.hops = initHops;
        if (self.hops == 1)
        {
            self.name = NSLocalizedString(@"Direct Flights", nil);
        }
        else
        {
            self.name = [NSString stringWithFormat:NSLocalizedString(@"%d stopover flights", nil), self.hops-1];
        }
    }
    return self;
}

@end
