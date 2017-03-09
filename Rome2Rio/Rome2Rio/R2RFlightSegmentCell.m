//
//  R2RFlightSegmentCell.m
//  R2RApp
//
//  Created by Ash Verdoorn on 13/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RFlightSegmentCell.h"
#import "R2RFlightLeg.h"

#import "R2RConstants.h"

@implementation R2RFlightSegmentCell

@synthesize flightLeg, firstAirlineIcon, secondAirlineIcon, sTimeLabel, tTimeLabel, durationLabel;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initSubviews];
    }	
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)initSubviews
{
    [self setClipsToBounds:YES];
    
    CGRect rect = CGRectMake(5, 4, 27, 23);
    self.firstAirlineIcon = [[UIImageView alloc] initWithFrame:rect];
    [self addSubview:self.firstAirlineIcon];
    
    rect = CGRectMake(35, 4, 27, 23);
    self.secondAirlineIcon = [[UIImageView alloc] initWithFrame:rect];
    [self addSubview:self.secondAirlineIcon];
    
    rect = CGRectMake((self.bounds.size.width/2)-10-50, 3, 50, 25);
    self.sTimeLabel = [[UILabel alloc] initWithFrame:rect];
    [self.sTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.sTimeLabel setBackgroundColor:[UIColor clearColor]];
    [self.sTimeLabel setTextColor:[R2RConstants getDarkTextColor]];
    [self addSubview:self.sTimeLabel];
    
    rect = CGRectMake((self.bounds.size.width/2)+10, 3, 50, 25);
    self.tTimeLabel = [[UILabel alloc] initWithFrame:rect];
    [self.tTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.tTimeLabel setBackgroundColor:[UIColor clearColor]];
    [self.tTimeLabel setTextColor:[R2RConstants getDarkTextColor]];
    [self addSubview:self.tTimeLabel];
    
    rect = CGRectMake(self.bounds.size.width-80, 3, 70, 25);
    self.durationLabel = [[UILabel alloc] initWithFrame:rect];
    [self.durationLabel setTextAlignment:NSTextAlignmentRight];
    [self.durationLabel setBackgroundColor:[UIColor clearColor]];
    [self.durationLabel setFont:[UIFont systemFontOfSize:11]];
    [self.durationLabel setTextColor:[R2RConstants getDarkTextColor]];
    [self addSubview:self.durationLabel];
    
    }

-(void)setDisplaySingleIcon
{
    [self.secondAirlineIcon setHidden:YES];
}

-(void)setDisplayDoubleIcon
{
    [self.secondAirlineIcon setHidden:NO];
}

@end
