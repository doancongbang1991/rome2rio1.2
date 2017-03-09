//
//  R2RFlightSegment.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 4/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "R2RFlightItinerary.h"
#import "R2RIndicativePrice.h"

@interface R2RFlightSegment : NSObject

@property (strong, nonatomic) NSString *kind;
@property (nonatomic) float distance;
@property (nonatomic) float duration;
@property (strong, nonatomic) NSString *sCode;
@property (strong, nonatomic) NSString *tCode;
@property (nonatomic) BOOL isMajor;
@property (strong, nonatomic) R2RIndicativePrice *indicativePrice;

@property (strong, nonatomic) NSMutableArray *itineraries;

@end
