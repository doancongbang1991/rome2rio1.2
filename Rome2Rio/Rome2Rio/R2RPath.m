//
//  R2RPath.m
//  Rome2Rio
//
//  Created by Bernie Tschirren.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RPath.h"

@interface R2RPath ()

@property (strong, nonatomic) NSArray *positions;

@end


@implementation R2RPath

@synthesize positions;

-(id) init
{
	self = [super init];
	if (self != nil)
	{
		self.positions = [[NSMutableArray alloc] init];
	}

	return self;
}

-(NSString *)description 
{
	return [self->positions description];
}

-(void) addPosition:(R2RPosition *)position
{
	[self->positions addObject:position];
}

@end