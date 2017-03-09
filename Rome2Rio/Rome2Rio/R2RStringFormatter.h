//
//  R2RStringFormatters.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 20/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "R2RIndicativePrice.h"

@interface R2RStringFormatter : NSObject

+(NSString *) formatFlightHopCellDuration:(float) minutes;
+(NSString *) formatFlightHopCellStops:(NSInteger) stops;
+(NSString *) formatTransitHopCellDuration:(float) minutes changes:(NSInteger) changes vehicle:(NSString *) vehicle line:(NSString *) line;
+(NSString *) formatTransitHopCellFrequency:(float) frequency;
+(NSString *) formatWalkDriveHopCellDuration:(float) minutes vehicle:(NSString *) vehicle;
+(NSString *) formatWalkDriveHopCellDistance:(float) distance isImperial:(bool) isImperial;

+(NSString *) formatTransitHopVehicle: (NSString *) vehicle;
+(NSString *) formatDuration: (float) minutes;
+(NSString *) formatDurationZeroPadded: (float) minutes;
+(NSString *) formatFrequency: (float) frequency;
+(NSString *) formatDistance: (float) distance isImperial: (bool) isImperial;
+(NSString *) formatDays: (NSInteger) days;

+(NSString *) capitaliseFirstLetter: (NSString *) string;

+(NSString *) formatIndicativePrice: (R2RIndicativePrice *) indicativePrice;

@end
