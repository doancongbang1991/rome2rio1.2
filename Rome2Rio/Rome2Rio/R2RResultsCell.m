//
//  R2RResultsCell.m
//  R2RApp
//
//  Created by Ash Verdoorn on 7/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RResultsCell.h"
#import "R2RConstants.h"

@interface R2RResultsCell()

@end


@implementation R2RResultsCell

@synthesize resultDescripionLabel, resultDurationLabel, resultPriceLabel, iconCount, icons;

-(id)initWithCoder:(NSCoder *)aDecoder
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

- (void) initSubviews
{    
    CGRect rect = CGRectMake(15, 5, self.bounds.size.width-120, 25);
    self.resultDescripionLabel = [[UILabel alloc] initWithFrame:rect];
    [self.resultDescripionLabel setMinimumScaleFactor:0.6];
    [self.resultDescripionLabel setAdjustsFontSizeToFitWidth:YES];
    [self.resultDescripionLabel setBackgroundColor:[UIColor clearColor]];
    [self.resultDescripionLabel setTextColor:[R2RConstants getDarkTextColor]];
    [self addSubview:self.resultDescripionLabel];
    
    rect = CGRectMake(15, 30, 100.0, 20);
    self.resultDurationLabel = [[UILabel alloc] initWithFrame:rect];
    [self.resultDurationLabel setTextAlignment:NSTextAlignmentLeft];
    [self.resultDurationLabel setFont:[UIFont systemFontOfSize:10.0]];
    [self.resultDurationLabel setBackgroundColor:[UIColor clearColor]];
    [self.resultDurationLabel setMinimumScaleFactor:0.6];
    [self.resultDurationLabel setAdjustsFontSizeToFitWidth:YES];
    [self.resultDurationLabel setTextColor:[R2RConstants getLightTextColor]];
    [self addSubview:self.resultDurationLabel];
    
    rect = CGRectMake(self.bounds.size.width-132, 30, 100.0, 20);
    self.resultPriceLabel = [[UILabel alloc] initWithFrame:rect];
    [self.resultPriceLabel setTextAlignment:NSTextAlignmentRight];
    [self.resultPriceLabel setFont:[UIFont systemFontOfSize:15.0]];
    [self.resultPriceLabel setBackgroundColor:[UIColor clearColor]];
    [self.resultPriceLabel setMinimumScaleFactor:0.6];
    [self.resultPriceLabel setAdjustsFontSizeToFitWidth:YES];
    [self.resultPriceLabel setTextColor:[R2RConstants getButtonHighlightColor]];
    [self addSubview:self.resultPriceLabel];
    
    self.icons = [[NSMutableArray alloc] initWithCapacity:MAX_ICONS];
    
    for (int i = 0; i < MAX_ICONS; i++)
    {
        CGRect rect = CGRectMake(self.bounds.size.width-(53+(25*i)), 7, 22, 22);
        UIImageView *icon = [[UIImageView alloc] initWithFrame:rect];
        [self.icons addObject:icon];
        
        [self addSubview:[self.icons objectAtIndex:i]];
    }
    
    self.iconCount = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)setIconCount:(NSInteger)count
{
    iconCount = count;
    
    for (int i = 0; i < MAX_ICONS; i++)
    {
        UIImageView *icon = [self.icons objectAtIndex:i];
        if (i < count)
        {
            [icon setHidden:NO];
        }
        else
        {
            [icon setHidden:YES];
        }
    }
}

@end
