//
//  R2RSerializer.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 6/02/13.
//  Copyright (c) 2013 Rome2Rio. All rights reserved.
//

#import "R2RSerializer.h"

@implementation R2RSerializer

+(NSString *)serializePlace:(R2RPlace *)place
{ 
    NSMutableString *placeString = [[NSMutableString alloc] init];
    
    [placeString appendString:place.longName];
    [placeString appendFormat:@"\t%@",place.shortName];
    [placeString appendFormat:@"\t%@",place.countryCode];
    [placeString appendFormat:@"\t%@",place.countryName];
    [placeString appendFormat:@"\t%@",place.kind];
    [placeString appendFormat:@"\t%f",place.lat];
    [placeString appendFormat:@"\t%f",place.lng];
    [placeString appendFormat:@"\t%@",place.rad];
    [placeString appendFormat:@"\t%@",place.regionCode];
    [placeString appendFormat:@"\t%@",place.regionName];
    [placeString appendFormat:@"\t%@",(place.code == nil) ? @"" : place.code];
    
    return placeString;
}

+(R2RPlace *) deserializePlace:(NSString *) placeString
{
    NSArray *splitPlaceString = [placeString componentsSeparatedByString:@"\t"];
    
    R2RPlace *place = [[R2RPlace alloc] init];
    
    place.longName = [splitPlaceString objectAtIndex:0];
    place.shortName = [splitPlaceString objectAtIndex:1];
    place.countryCode = [splitPlaceString objectAtIndex:2];
    place.countryName = [splitPlaceString objectAtIndex:3];
    place.kind = [splitPlaceString objectAtIndex:4];
    place.lat = [[splitPlaceString objectAtIndex:5] floatValue];
    place.lng = [[splitPlaceString objectAtIndex:6] floatValue];
    place.rad = [splitPlaceString objectAtIndex:7];
    place.regionCode = [splitPlaceString objectAtIndex:8];
    place.regionName = [splitPlaceString objectAtIndex:9];
    place.code = [splitPlaceString objectAtIndex:10];

    return place;
}

@end
