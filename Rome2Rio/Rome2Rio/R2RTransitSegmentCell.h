//
//  R2RTransitSegmentCell.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 13/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "R2RSearchButton.h"

@interface R2RTransitSegmentCell : UITableViewCell

@property (strong, nonatomic) UIImageView *transitVehicleIcon;
@property (strong, nonatomic) UILabel *fromLabel;
@property (strong, nonatomic) UILabel *toLabel;
@property (strong, nonatomic) UILabel *durationLabel;
@property (strong, nonatomic) UILabel *frequencyLabel;
@property (strong, nonatomic) UILabel *lineLabel;
@property (strong, nonatomic) R2RSearchButton *schedulesButton;

@end
