//
//  R2RTransitHopCell.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 14/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RTransitHopCell.h"

@implementation R2RTransitHopCell

@synthesize hopLabel, hopPrice, hopFrequency, connectTop, connectBottom, icon;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
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
    int cellHeight = 54; // needs to match DetailViewController heightForRowAtIndexPath
    
    self.connectTop = [[UIImageView alloc] initWithFrame:CGRectMake(25, 0, 6, cellHeight/2)];
    [self.contentView addSubview:connectTop];
    
    self.connectBottom = [[UIImageView alloc] initWithFrame:CGRectMake(25, cellHeight/2, 6, cellHeight/2)];
    [self.contentView addSubview:connectBottom];
    
    self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(16, cellHeight/2-12, 24, 24)];
    [self.contentView addSubview:icon];
}

@end

