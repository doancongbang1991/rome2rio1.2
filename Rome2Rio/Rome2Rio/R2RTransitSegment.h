//
//  R2RTransitSegment.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 4/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "R2RPosition.h"
#import "R2RTransitItinerary.h"
#import "R2RIndicativePrice.h"

@interface R2RTransitSegment : NSObject

@property (strong, nonatomic) NSString *kind;
@property (strong, nonatomic) NSString *subkind;
@property (nonatomic) float distance;
@property (nonatomic) float duration;
@property (strong, nonatomic) NSString *sName;
@property (strong, nonatomic) R2RPosition *sPos;
@property (strong, nonatomic) NSString *tName;
@property (strong, nonatomic) R2RPosition *tPos;
@property (nonatomic) BOOL isMajor;
@property (nonatomic) BOOL isImperial;
@property (strong, nonatomic) NSString *vehicle;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) R2RIndicativePrice *indicativePrice;

@property (strong, nonatomic) NSMutableArray *itineraries;

@end
