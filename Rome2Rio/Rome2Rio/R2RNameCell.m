//
//  R2RNameCell.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 7/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RNameCell.h"

@implementation R2RNameCell

@synthesize nameLabel, icon, connectTop, connectBottom;


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
    self.connectTop = [[UIImageView alloc] initWithFrame:CGRectMake(25, 0, 6, self.contentView.bounds.size.height/2)];
    [self.contentView addSubview:connectTop];
    
    self.connectBottom = [[UIImageView alloc] initWithFrame:CGRectMake(25, self.contentView.bounds.size.height/2 + 1, 6, self.contentView.bounds.size.height/2)];
    [self.contentView addSubview:connectBottom];
    
    self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(22, self.contentView.bounds.size.height/2-6, 12, 12)];
    [self.contentView addSubview:icon];
}

@end
