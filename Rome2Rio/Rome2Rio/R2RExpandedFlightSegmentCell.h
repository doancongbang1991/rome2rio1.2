//
//  R2RExpandedFlightSegmentCell.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 8/11/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "R2RFlightLeg.h"

@interface R2RExpandedFlightSegmentCell : UITableViewCell

@property (strong, nonatomic) R2RFlightLeg *flightLeg;

@property (strong, nonatomic) UIImageView *firstAirlineIcon;
@property (strong, nonatomic) UIImageView *secondAirlineIcon;
@property (strong, nonatomic) UILabel *sTimeLabel;
@property (strong, nonatomic) UILabel *tTimeLabel;
@property (strong, nonatomic) UILabel *durationLabel;

@property (strong, nonatomic) UILabel *frequencyLabel;
@property (strong, nonatomic) UIButton *linkButton;
// for expanded cell view
@property (strong, nonatomic) NSMutableArray *airlineIcons;
@property (strong, nonatomic) NSMutableArray *airlineNameLabels;
@property (strong, nonatomic) NSMutableArray *layoverNameLabels;
@property (strong, nonatomic) NSMutableArray *hopDurationLabels;
@property (strong, nonatomic) NSMutableArray *layoverDurationLabels;
@property (strong, nonatomic) NSMutableArray *joinerLabels;
@property (strong, nonatomic) NSMutableArray *flightNameLabels;
@property (strong, nonatomic) NSMutableArray *sAirportLabels;
@property (strong, nonatomic) NSMutableArray *tAirportLabels;


-(void) setDisplaySingleIcon;
-(void) setDisplayDoubleIcon;

@end
