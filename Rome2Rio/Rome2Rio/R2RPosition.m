//
//  R2RPosition.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 31/08/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RPosition.h"

@implementation R2RPosition

@synthesize lat, lng;

- (NSString *)description 
{
	return [NSString stringWithFormat: @"%f, %f", self.lat, self.lng];
}

@end
