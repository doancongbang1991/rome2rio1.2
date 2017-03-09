//
//  R2RGeocodeData.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 4/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "R2RPlace.h"

@interface R2RGeocodeResponse : NSObject

@property (strong, nonatomic) NSString *query;
@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSString *languageCode;
@property (strong, nonatomic) NSMutableArray *places;

@end
