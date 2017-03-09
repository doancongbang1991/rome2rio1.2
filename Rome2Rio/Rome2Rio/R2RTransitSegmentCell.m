//
//  R2RTransitSegmentCell.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 13/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RTransitSegmentCell.h"
#import "R2RConstants.h"

@implementation R2RTransitSegmentCell

@synthesize fromLabel, durationLabel, frequencyLabel, toLabel, transitVehicleIcon, lineLabel, schedulesButton;

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
    if (self)
    {

    }
    return self;
}

-(void) initSubviews
{
    NSInteger paddingX = 20;
    NSInteger indent = 20;
    
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
    
    rect = CGRectMake(paddingX, 30, 18, 18);
    self.transitVehicleIcon = [[UIImageView alloc] initWithFrame:rect];
    [self addSubview:self.transitVehicleIcon];
    
    rect = CGRectMake(paddingX, 30, self.bounds.size.width - (paddingX + 5), 25);
    self.durationLabel = [[UILabel alloc] initWithFrame:rect];
    [self.durationLabel setTextAlignment:NSTextAlignmentCenter];
    [self.durationLabel setTextColor:[R2RConstants getLightTextColor]];
    [self.durationLabel setMinimumScaleFactor:0.6];
    [self.durationLabel setAdjustsFontSizeToFitWidth:YES];
    [self.durationLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.durationLabel];
    
    rect = CGRectMake(paddingX+indent, 55, self.bounds.size.width - (2*paddingX)-indent, 25);
    self.lineLabel = [[UILabel alloc] initWithFrame:rect];
    [self.lineLabel setTextAlignment:NSTextAlignmentLeft];
    [self.lineLabel setMinimumScaleFactor:0.6];
    [self.lineLabel setAdjustsFontSizeToFitWidth:YES];
    [self.lineLabel setBackgroundColor:[UIColor clearColor]];
    [self.lineLabel setTextColor:[R2RConstants getLightTextColor]];
    [self.lineLabel setHidden:YES];
    [self addSubview:self.lineLabel];
    
    rect = CGRectMake(self.bounds.size.width - 10 - 100, 80, 100, 25);
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0)
    {
        rect.origin.x = rect.origin.x - 10; // move button further across to account for <7.0 table cell style
    }
    self.schedulesButton = [R2RSearchButton buttonWithType:UIButtonTypeRoundedRect];
    [self.schedulesButton setFrame:rect];
    self.schedulesButton.tintColor = [R2RConstants getButtonHighlightColor];
    [self.schedulesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.schedulesButton setTitle:NSLocalizedString(@"Schedules", nil)  forState:UIControlStateNormal];
    self.schedulesButton.hidden = YES;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0)
    {
        [self.schedulesButton setTitleColor:[R2RConstants getButtonHighlightColor] forState:UIControlStateNormal];
    }
    [self addSubview:self.schedulesButton];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
