//
//  R2RTransitSegmentSectionHeader.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 1/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RFlightSegmentSectionHeader.h"
#import "R2RConstants.h"

@implementation R2RFlightSegmentSectionHeader

@synthesize titleLabel, routeLabel, iconView, priceText, segmentPrice;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[R2RConstants getBackgroundColor]];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, [R2RConstants getTableWidth] - 20, 25)];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.titleLabel];
     
        CGRect rect = CGRectMake(10, 30, [R2RConstants getTableWidth] - 20, 25);
        self.routeLabel = [[UILabel alloc] initWithFrame:rect];
        [self.routeLabel setTextAlignment:NSTextAlignmentCenter];
        [self.routeLabel setTextColor:[R2RConstants getLightTextColor]];
        [self.routeLabel setBackgroundColor:[UIColor clearColor]];
        [self.routeLabel setMinimumScaleFactor:0.6];
        [self.routeLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:self.routeLabel];
        
        rect = CGRectMake(10, 16, 24, 24);
        self.iconView = [[UIImageView alloc] initWithFrame:rect];
        [self addSubview:self.iconView];
        
        rect = CGRectMake([R2RConstants getTableWidth] - 85, 15, 75, 25);
        self.priceText = [[UILabel alloc] initWithFrame:rect];
        [self.priceText setTextAlignment:NSTextAlignmentRight];
        [self.priceText setFont:[UIFont systemFontOfSize:12.0]];
        [self.priceText setBackgroundColor:[UIColor clearColor]];
        [self.priceText setTextColor:[R2RConstants getLightTextColor]];
        [self addSubview:self.priceText];
        
        rect = CGRectMake([R2RConstants getTableWidth] - 85, 30, 75, 25);
        self.segmentPrice = [[UILabel alloc] initWithFrame:rect];
        [self.segmentPrice setTextAlignment:NSTextAlignmentRight];
        [self.segmentPrice setMinimumScaleFactor:0.6];
        [self.segmentPrice setAdjustsFontSizeToFitWidth:YES];
        [self.segmentPrice setBackgroundColor:[UIColor clearColor]];
        [self.segmentPrice setTextColor:[R2RConstants getButtonHighlightColor]];
        [self addSubview:self.segmentPrice];
    
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
