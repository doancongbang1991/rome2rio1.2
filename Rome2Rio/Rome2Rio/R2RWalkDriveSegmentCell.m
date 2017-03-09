//
//  R2RWalkDriveSegmentCell.m
//  R2RApp
//
//  Created by Ash Verdoorn on 13/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RWalkDriveSegmentCell.h"
#import "R2RConstants.h"

@implementation R2RWalkDriveSegmentCell

@synthesize kindIcon, distanceLabel, durationLabel, fromLabel, toLabel;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setBackgroundColor:[R2RConstants getCellColor]];
        [self initSubviews];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) initSubviews
{
    NSInteger paddingX = 20;
    
    CGRect rect = CGRectMake(paddingX, 5, self.bounds.size.width - (2*paddingX), 25);
    self.fromLabel = [[UILabel alloc] initWithFrame:rect];
    [self.fromLabel setTextAlignment:NSTextAlignmentLeft];
    [self.fromLabel setMinimumScaleFactor:0.6];
    [self.fromLabel setAdjustsFontSizeToFitWidth:YES];
    [self.fromLabel setBackgroundColor:[UIColor clearColor]];
    [self.fromLabel setTextColor:[R2RConstants getDarkTextColor]];
    [self addSubview:self.fromLabel];
    
    rect = CGRectMake(paddingX, 55, self.bounds.size.width - (2*paddingX), 25);
    self.toLabel = [[UILabel alloc] initWithFrame:rect];
    [self.toLabel setTextAlignment:NSTextAlignmentLeft];
    [self.toLabel setMinimumScaleFactor:0.6];
    [self.toLabel setAdjustsFontSizeToFitWidth:YES];
    [self.toLabel setBackgroundColor:[UIColor clearColor]];
    [self.toLabel setTextColor:[R2RConstants getDarkTextColor]];
    [self addSubview:self.toLabel];
    
    rect = CGRectMake(paddingX+20, 34, 18, 18);
    self.kindIcon = [[UIImageView alloc] initWithFrame:rect];
    [self addSubview:self.kindIcon];
    
    rect = CGRectMake(paddingX+20+25, 30, self.bounds.size.width - 75, 25);
    self.distanceLabel = [[UILabel alloc] initWithFrame:rect];
    [self.distanceLabel setTextAlignment:NSTextAlignmentLeft];
    [self.distanceLabel setBackgroundColor:[UIColor clearColor]];
    [self.distanceLabel setTextColor:[R2RConstants getLightTextColor]];
    [self addSubview:self.distanceLabel];
    
    rect = CGRectMake(self.bounds.size.width-75, 30, 60.0, 25);
    self.durationLabel = [[UILabel alloc] initWithFrame:rect];
    [self.durationLabel setTextAlignment:NSTextAlignmentLeft];
    [self.durationLabel setMinimumScaleFactor:0.6];
    [self.durationLabel setAdjustsFontSizeToFitWidth:YES];
    [self.durationLabel setBackgroundColor:[UIColor clearColor]];
    [self.durationLabel setTextColor:[R2RConstants getLightTextColor]];
    [self addSubview:self.durationLabel];
}

@end
