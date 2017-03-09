//
//  R2RTransitSegmentSectionHeader.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 1/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface R2RFlightSegmentSectionHeader : UIView

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *routeLabel;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *priceText;
@property (strong, nonatomic) UILabel *segmentPrice;

@end
