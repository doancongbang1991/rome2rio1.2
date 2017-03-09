//
//  R2RMasterViewStatusButton.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 2/11/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RMasterViewStatusButton.h"

@implementation R2RMasterViewStatusButton

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self != nil)
    {
        self.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.titleLabel setMinimumScaleFactor:0.6];
        [self.titleLabel setAdjustsFontSizeToFitWidth:YES];
        
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        [self setHidden:true];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    }
    
    return self;
}

- (void) setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    
    if ([title length] == 0)
    {
        self.hidden = true;
    }
    else
    {
        self.hidden = false;
    }
}


@end
