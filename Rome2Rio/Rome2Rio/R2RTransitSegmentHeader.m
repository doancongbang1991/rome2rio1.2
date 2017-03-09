//
//  R2RTransitSegmentHeader.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 1/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RTransitSegmentHeader.h"
#import "R2RConstants.h"

@implementation R2RTransitSegmentHeader

@synthesize agencyIconView, agencyNameLabel, segmentPrice;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
       [self initSubviews];
    }
    return self;
}


-(void) initSubviews
{
    CGRect rect = CGRectMake(19, 5, 24, 24);
    
    self.agencyIconView = [[UIImageView alloc] initWithFrame:rect];
    [self addSubview:self.agencyIconView];
    
    float width = [R2RConstants getTableWidth] - 150;
    rect = CGRectMake(55, 6, width, 25);
    self.agencyNameLabel = [[UILabel alloc] initWithFrame:rect];
    [self.agencyNameLabel setTextAlignment:NSTextAlignmentLeft];
    [self.agencyNameLabel setMinimumScaleFactor:0.6];
    [self.agencyNameLabel setAdjustsFontSizeToFitWidth:YES];
    [self.agencyNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.agencyNameLabel setTextColor:[R2RConstants getDarkTextColor]];
    [self addSubview:self.agencyNameLabel];

    float x = [R2RConstants getTableWidth] - 90;
    rect = CGRectMake(x, 6, 75, 25);
    self.segmentPrice = [[UILabel alloc] initWithFrame:rect];
    [self.segmentPrice setTextAlignment:NSTextAlignmentRight];
    [self.segmentPrice setMinimumScaleFactor:0.6];
    [self.segmentPrice setAdjustsFontSizeToFitWidth:YES];
    [self.segmentPrice setBackgroundColor:[UIColor clearColor]];
    [self.segmentPrice setTextColor:[R2RConstants getButtonHighlightColor]];
    [self addSubview:self.segmentPrice];
    
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
