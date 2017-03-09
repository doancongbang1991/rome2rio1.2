//
//  R2RResultsCell.h
//  R2RApp
//
//  Created by Ash Verdoorn on 7/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface R2RResultsCell : UITableViewCell

@property (strong, nonatomic) UILabel *resultDescripionLabel;
@property (strong, nonatomic) UILabel *resultDurationLabel;
@property (strong, nonatomic) UILabel *resultPriceLabel;
@property (nonatomic) NSInteger iconCount;
@property (strong, nonatomic) NSMutableArray *icons;

@end
