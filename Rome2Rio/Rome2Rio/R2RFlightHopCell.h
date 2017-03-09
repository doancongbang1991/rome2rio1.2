//
//  R2RFlightHopCell.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 14/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface R2RFlightHopCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *hopLabel;
@property (weak, nonatomic) IBOutlet UILabel *hopPrice;
@property (weak, nonatomic) IBOutlet UILabel *hopStops;
@property (strong, nonatomic) UIImageView *icon;
@property (strong, nonatomic) UIImageView *connectTop;
@property (strong, nonatomic) UIImageView *connectBottom;

@end
