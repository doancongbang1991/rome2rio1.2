//
//  R2RSearchButton.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 18/12/2013.
//  Copyright (c) 2013 Rome2Rio. All rights reserved.
//

#import "R2RSearchButton.h"
#import "R2RConstants.h"

@implementation R2RSearchButton

- (void)initButton
{
    self.layer.borderWidth = 1;
    self.layer.borderColor = [R2RConstants getButtonHighlightColor].CGColor;
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
    
    self.backgroundColor = [R2RConstants getButtonHighlightColor];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0)
    {
        [self setTitleColor:[R2RConstants getButtonHighlightDarkerColor] forState:UIControlStateHighlighted];
    }
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initButton];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initButton];
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
