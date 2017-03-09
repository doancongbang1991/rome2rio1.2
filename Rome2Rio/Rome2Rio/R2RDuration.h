//
//  R2RDuration.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 20/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface R2RDuration : NSObject

@property (readonly) NSInteger days;
@property (readonly) NSInteger hours;
@property (readonly) NSInteger minutes;
@property (readonly) NSInteger totalHours;
@property NSInteger totalMinutes;

-(id) initWithMinutes: (float) totalMinutes;

@end
