//
//  R2RTableView.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 29/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "R2RTableView.h"

@implementation R2RTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    }
    return self;
}

-(void)reloadData
{
    [super reloadData];
    
    if ([self.delegate conformsToProtocol:@protocol(R2RTableViewDelegate)])
    {
        id<R2RTableViewDelegate> myDelegate = (id<R2RTableViewDelegate>)self.delegate;
        [myDelegate reloadDataDidFinish];
    }
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
