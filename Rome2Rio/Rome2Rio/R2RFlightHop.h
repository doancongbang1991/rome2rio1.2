//
//  R2RFlightHop.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 4/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface R2RFlightHop : NSObject

@property (strong, nonatomic) NSString *sCode;
@property (strong, nonatomic) NSString *tCode;
@property (strong, nonatomic) NSString *sTime;
@property (strong, nonatomic) NSString *tTime;
@property (strong, nonatomic) NSString *airline;
@property (strong, nonatomic) NSString *flight;
@property (nonatomic) float duration;
@property (nonatomic) int dayChange;
@property (nonatomic) float lDuration;
@property (nonatomic) int lDayChange;

@end
