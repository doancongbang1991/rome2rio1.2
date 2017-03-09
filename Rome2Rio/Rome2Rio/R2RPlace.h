//
//  R2RPlace.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 31/08/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface R2RPlace : NSObject

@property(strong, nonatomic)NSString *longName;
@property(strong, nonatomic)NSString *shortName;
@property(strong, nonatomic)NSString *countryCode;
@property(strong, nonatomic)NSString *countryName;
@property(strong, nonatomic)NSString *kind;
@property(nonatomic)float lat;
@property(nonatomic)float lng;
@property(strong, nonatomic)NSString *rad;
@property(strong, nonatomic)NSString *regionCode;
@property(strong, nonatomic)NSString *regionName;
@property(strong, nonatomic)NSString *code;



@end
