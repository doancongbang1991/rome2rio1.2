//
//  R2RResultSectionHeader.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 1/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RResultSectionHeader.h"
#import "R2RConstants.h"

@implementation R2RResultSectionHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[R2RConstants getBackgroundColor]];
        
        CGRect rect = CGRectMake(10, 5, self.bounds.size.width - 10, 25);
        self.titleLabel = [[UILabel alloc] initWithFrame:rect];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setTextColor:[R2RConstants getDarkTextColor]];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setMinimumScaleFactor:0.6];
        [self.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:self.titleLabel];
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
