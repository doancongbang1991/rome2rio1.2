//
//  R2RSegmentHandler.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 26/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RSegmentHelper.h"
#import "R2RConstants.h"

@interface R2RSegmentHelper()

@property (strong, nonatomic) R2RSearchStore *dataStore;

@end

@implementation R2RSegmentHelper

+(id) alloc
{
    [NSException raise:@"R2RSegmentHelper is static" format:@"R2RSegmentHelper is static"];
    return nil;
}

+(BOOL) getSegmentIsMajor:(id) segment
{
    if([segment isKindOfClass:[R2RWalkDriveSegment class]])
    {
        R2RWalkDriveSegment *currentSegment = segment;
        return currentSegment.isMajor;
    }
    else if([segment isKindOfClass:[R2RTransitSegment class]])
    {
        R2RTransitSegment *currentSegment = segment;
        return currentSegment.isMajor;
    }
    else if([segment isKindOfClass:[R2RFlightSegment class]])
    {
        R2RFlightSegment *currentSegment = segment;
        return currentSegment.isMajor;
    }
    
    return NO;
}

+(NSString*) getSegmentKind:(id) segment
{
    if([segment isKindOfClass:[R2RWalkDriveSegment class]])
    {
        R2RWalkDriveSegment *currentSegment = segment;
        return currentSegment.kind;
    }
    else if([segment isKindOfClass:[R2RTransitSegment class]])
    {
        R2RTransitSegment *currentSegment = segment;
        return currentSegment.kind;
    }
    else if([segment isKindOfClass:[R2RFlightSegment class]])
    {
        R2RFlightSegment *currentSegment = segment;
        return currentSegment.kind;
    }
    
    return nil;
}

+(NSString*) getSegmentSubkind:(id) segment
{
    // if subkind is unknown return kind
    if([segment isKindOfClass:[R2RWalkDriveSegment class]])
    {
        R2RWalkDriveSegment *currentSegment = segment;
        return ([R2RSegmentHelper subkindIsHandled: currentSegment.subkind]) ? currentSegment.subkind : currentSegment.kind;
    }
    else if([segment isKindOfClass:[R2RTransitSegment class]])
    {
        R2RTransitSegment *currentSegment = segment;
        return ([R2RSegmentHelper subkindIsHandled: currentSegment.subkind]) ? currentSegment.subkind : currentSegment.kind;
    }
    else if([segment isKindOfClass:[R2RFlightSegment class]])
    {
        R2RFlightSegment *currentSegment = segment;
        return currentSegment.kind;
    }
    
    return nil;
}

// subkinds we currently know about
+(BOOL) subkindIsHandled:(NSString *) subkind
{
    if ([subkind isEqualToString:@"plane"]) return true;
    if ([subkind isEqualToString:@"helicopter"]) return true;
    if ([subkind isEqualToString:@"bus"]) return true;
    if ([subkind isEqualToString:@"taxi"]) return true;
    if ([subkind isEqualToString:@"car"]) return true;
    if ([subkind isEqualToString:@"rideshare"]) return true;
    if ([subkind isEqualToString:@"busferry"]) return true;
    if ([subkind isEqualToString:@"shuttle"]) return true;
    if ([subkind isEqualToString:@"train"]) return true;
    if ([subkind isEqualToString:@"tram"]) return true;
    if ([subkind isEqualToString:@"cablecar"]) return true;
    if ([subkind isEqualToString:@"subway"]) return true;
    if ([subkind isEqualToString:@"ferry"]) return true;
    if ([subkind isEqualToString:@"carferry"]) return true;
    if ([subkind isEqualToString:@"walk"]) return true;
    if ([subkind isEqualToString:@"animal"]) return true;
    if ([subkind isEqualToString:@"cycle"]) return true;
    if ([subkind isEqualToString:@"unknown"]) return true;
    if ([subkind isEqualToString:@"towncar"]) return true;
    return false;
}

+(NSString*) getSegmentPath:(id)segment
{
    if([segment isKindOfClass:[R2RWalkDriveSegment class]])
    {
        R2RWalkDriveSegment *currentSegment = segment;
        return currentSegment.path;
    }
    else if([segment isKindOfClass:[R2RTransitSegment class]])
    {
        R2RTransitSegment *currentSegment = segment;
        return currentSegment.path;
    }
    else if([segment isKindOfClass:[R2RFlightSegment class]])
    {
        return nil;
    }
    
    return nil;
}

//used to return start coordinate for any segment including flights
+(R2RPosition *) getSegmentSPos:(id) segment store:(R2RSearchStore *)dataStore
{
    if([segment isKindOfClass:[R2RWalkDriveSegment class]])
    {
        R2RWalkDriveSegment *currentSegment = (R2RWalkDriveSegment *)segment;
        return currentSegment.sPos;
    }
    else if([segment isKindOfClass:[R2RTransitSegment class]])
    {
        R2RTransitSegment *currentSegment = (R2RTransitSegment *)segment;
        return currentSegment.sPos;
    }
    else if([segment isKindOfClass:[R2RFlightSegment class]])
    {
        R2RFlightSegment *currentSegment = (R2RFlightSegment *)segment;
        R2RFlightItinerary *itinerary = [currentSegment.itineraries objectAtIndex:0];
        R2RFlightLeg *leg = [itinerary.legs objectAtIndex:0];
        R2RFlightHop *hop = [leg.hops objectAtIndex:0];
        R2RAirport *airport = [dataStore getAirport:hop.sCode];
        
        return airport.pos;
    }
    
    return nil;
}

//used to return end coordinate for any segment including flights
+(R2RPosition *) getSegmentTPos:(id) segment store:(R2RSearchStore *)dataStore
{
    if([segment isKindOfClass:[R2RWalkDriveSegment class]])
    {
        R2RWalkDriveSegment *currentSegment = (R2RWalkDriveSegment *)segment;
        return currentSegment.tPos;
    }
    else if([segment isKindOfClass:[R2RTransitSegment class]])
    {
        R2RTransitSegment *currentSegment = (R2RTransitSegment *)segment;
        return currentSegment.tPos;
    }
    else if([segment isKindOfClass:[R2RFlightSegment class]])
    {
        R2RFlightSegment *currentSegment = (R2RFlightSegment *)segment;
        R2RFlightItinerary *itinerary = [currentSegment.itineraries objectAtIndex:0];
        R2RFlightLeg *leg = [itinerary.legs objectAtIndex:0];
        R2RFlightHop *hop = [leg.hops lastObject];
        R2RAirport *airport = [dataStore getAirport:hop.tCode];
        
        return airport.pos;
    }
    
    return nil;
}

+(R2RIndicativePrice *)getSegmentIndicativePrice:(id)segment
{
    if([segment isKindOfClass:[R2RWalkDriveSegment class]])
    {
        R2RWalkDriveSegment *currentSegment = segment;
        return currentSegment.indicativePrice;
    }
    else if([segment isKindOfClass:[R2RTransitSegment class]])
    {
        R2RTransitSegment *currentSegment = segment;
        return currentSegment.indicativePrice;
    }
    else if([segment isKindOfClass:[R2RFlightSegment class]])
    {
        R2RFlightSegment *currentSegment = segment;
        return currentSegment.indicativePrice;
    }
    
    return nil;
}

+(CGRect) getRouteIconRect: (NSString *) kind
{
    if ([kind isEqualToString:@"flight"] || [kind isEqualToString:@"plane"])
    {
        return [R2RConstants getRouteFlightSpriteRect];
    }
    else if ([kind isEqualToString:@"helicopter"])
    {
        return [R2RConstants getRouteHelicopterSpriteRect];
    }
    else if ([kind isEqualToString:@"train"] || [kind isEqualToString:@"subway"])
    {
        return [R2RConstants getRouteTrainSpriteRect];
    }
    else if ([kind isEqualToString:@"tram"])
    {
        return [R2RConstants getRouteTramSpriteRect];
    }
    else if ([kind isEqualToString:@"cablecar"])
    {
        return [R2RConstants getRouteCablecarSpriteRect];
    }
    else if ([kind isEqualToString:@"bus"] || [kind isEqualToString:@"busferry"] || [kind isEqualToString:@"shuttle"])
    {
        return [R2RConstants getRouteBusSpriteRect];
    }
    else if ([kind isEqualToString:@"ferry"] || [kind isEqualToString:@"carferry"])
    {
        return [R2RConstants getRouteFerrySpriteRect];
    }
    else if ([kind isEqualToString:@"car"] || [kind isEqualToString:@"towncar"])
    {
        return [R2RConstants getRouteCarSpriteRect];
    }
    else if ([kind isEqualToString:@"taxi"])
    {
        return [R2RConstants getRouteTaxiSpriteRect];
    }
    else if ([kind isEqualToString:@"rideshare"])
    {
        return [R2RConstants getRouteRideshareSpriteRect];
    }
    else if ([kind isEqualToString:@"walk"])
    {
        return [R2RConstants getRouteWalkSpriteRect];
    }
    else if ([kind isEqualToString:@"animal"])
    {
        return [R2RConstants getRouteAnimalSpriteRect];
    }
    else if ([kind isEqualToString:@"cycle"])
    {
        return [R2RConstants getRouteBikeSpriteRect];
    }
    else
    {
        return [R2RConstants getRouteUnknownSpriteRect];
    }
}

+(R2RSprite *) getRouteSprite:(NSString *)kind
{
    CGRect rect = [R2RSegmentHelper getRouteIconRect:kind];
    R2RSprite *sprite = [[R2RSprite alloc] initWithPath:[R2RConstants getIconSpriteFileName] :rect.origin :rect.size];
    return sprite;
}

+(R2RSprite *)getExternalLinkWhiteSprite
{
    CGRect rect = [R2RConstants getExternalLinkWhiteIconRect];
    R2RSprite *sprite = [[R2RSprite alloc] initWithPath:[R2RConstants getIconSpriteFileName] :rect.origin :rect.size];
    return sprite;
}

+(R2RSprite *)getExternalLinkPinkSprite
{
    CGRect rect = [R2RConstants getExternalLinkPinkIconRect];
    R2RSprite *sprite = [[R2RSprite alloc] initWithPath:[R2RConstants getIconSpriteFileName] :rect.origin :rect.size];
    return sprite;
}

+(NSInteger) getTransitHopCount:(R2RTransitSegment *)segment
{
    NSInteger hopCount = 0;

    if ([segment.itineraries count] >= 1)
    {
        R2RTransitItinerary *itinerary = [segment.itineraries objectAtIndex:0];
        for (R2RTransitLeg *leg in itinerary.legs)
        {
            hopCount += [leg.hops count];
        }
    }
    
    return hopCount;
}

+(NSInteger) getTransitChangeCount:(R2RTransitSegment *)segment
{
    NSInteger hopCount = [R2RSegmentHelper getTransitHopCount:segment];
    return (hopCount - 1);//1 less change than hops;
}

+(float) getTransitFrequency: (R2RTransitSegment *)segment
{
    NSInteger hopCount = [R2RSegmentHelper getTransitHopCount:segment];
    if (hopCount == 1)
    {
        R2RTransitItinerary *itinerary = [segment.itineraries objectAtIndex:0];
        R2RTransitLeg *transitLeg = [itinerary.legs objectAtIndex:0];
        R2RTransitHop *hop = [transitLeg.hops objectAtIndex:0];
        return hop.frequency;
    }
    return 0.0;
}


// return the transit line if there is only 1
+(NSString *)getTransitLine:(R2RTransitSegment *)segment
{
    if ([segment.itineraries count] != 1)
        return NULL;
    
    R2RTransitItinerary *transitItinerary = [segment.itineraries objectAtIndex:0];
    
    if ([transitItinerary.legs count] != 1)
        return NULL;
    
    R2RTransitLeg *transitLeg = [transitItinerary.legs objectAtIndex:0];
    
    if ([transitLeg.hops count] != 1)
        return NULL;
    
    R2RTransitHop *transitHop = [transitLeg.hops objectAtIndex:0];
    
    if ([transitHop.lines count] == 1)
    {
        R2RTransitLine *line = [transitHop.lines objectAtIndex:0];
        return line.name;
    }
    
    return NULL;
}

+(R2RSprite *)getConnectionSprite:(id)segment
{
    NSString *kind = [R2RSegmentHelper getSegmentSubkind:segment];
    CGSize size = CGSizeMake(10, 50);
    R2RSprite *sprite;

    if ([kind isEqualToString:@"flight"] || [kind isEqualToString:@"plane"] || [kind isEqualToString:@"helicopter"])
    {
        CGPoint offset = CGPointMake(0, 0);
        sprite = [[R2RSprite alloc] initWithPath:[R2RConstants getConnectionsImageFileName] :offset :size];
        return sprite;
    }
    else if ([kind isEqualToString:@"train"] || [kind isEqualToString:@"tram"] || [kind isEqualToString:@"cablecar"] || [kind isEqualToString:@"subway"])
    {
        CGPoint offset = CGPointMake(10, 0);
        sprite = [[R2RSprite alloc] initWithPath:[R2RConstants getConnectionsImageFileName] :offset :size];
        return sprite;
    }
    else if ([kind isEqualToString:@"bus"] || [kind isEqualToString:@"busferry"] || [kind isEqualToString:@"shuttle"])
    {
        CGPoint offset = CGPointMake(20, 0);
        sprite = [[R2RSprite alloc] initWithPath:[R2RConstants getConnectionsImageFileName] :offset :size];
        return sprite;
    }
    else if ([kind isEqualToString:@"car"] || [kind isEqualToString:@"towncar"])
    {
        CGPoint offset = CGPointMake(30, 0);
        R2RSprite *sprite = [[R2RSprite alloc] initWithPath:[R2RConstants getConnectionsImageFileName] :offset :size];
        return sprite;
    }
    else if ([kind isEqualToString:@"taxi"])
    {
        CGPoint offset = CGPointMake(70, 0);
        sprite = [[R2RSprite alloc] initWithPath:[R2RConstants getConnectionsImageFileName] :offset :size];
        return sprite;
    }
    else if ([kind isEqualToString:@"ferry"] || [kind isEqualToString:@"carferry"])
    {
        CGPoint offset = CGPointMake(40, 0);
        sprite = [[R2RSprite alloc] initWithPath:[R2RConstants getConnectionsImageFileName] :offset :size];
        return sprite;
    }
    else if ([kind isEqualToString:@"walk"] || [kind isEqualToString:@"animal"] || [kind isEqualToString:@"rideshare"])
    {
        CGPoint offset = CGPointMake(60, 0);
         sprite = [[R2RSprite alloc] initWithPath:[R2RConstants getConnectionsImageFileName] :offset :size];
    }
    else if ([kind isEqualToString:@"cycle"])
    {
        CGPoint offset = CGPointMake(80, 0);
        sprite = [[R2RSprite alloc] initWithPath:[R2RConstants getConnectionsImageFileName] :offset :size];
    }
    else {
        CGPoint offset = CGPointMake(50, 0);
        sprite = [[R2RSprite alloc] initWithPath:[R2RConstants getConnectionsImageFileName] :offset :size];
    }
    
    return sprite;
}

+(UIColor *)getSegmentColorWithKind:(NSString *)kind
{
    if ([kind isEqualToString:@"flight"] || [kind isEqualToString:@"plane"] || [kind isEqualToString:@"helicopter"])
    {
        return [R2RConstants getFlightColor];
    }
    else if ([kind isEqualToString:@"train"] || [kind isEqualToString:@"tram"] || [kind isEqualToString:@"cablecar"] || [kind isEqualToString:@"subway"])
    {
        return [R2RConstants getTrainColor];
    }
    else if ([kind isEqualToString:@"bus"] || [kind isEqualToString:@"busferry"] || [kind isEqualToString:@"shuttle"])
    {
        return [R2RConstants getBusColor];
    }
    else if ([kind isEqualToString:@"car"] || [kind isEqualToString:@"towncar"])
    {
        return [R2RConstants getDriveColor];
    }
    else if ([kind isEqualToString:@"taxi"])
    {
        return [R2RConstants getTaxiColor];
    }
    else if ([kind isEqualToString:@"ferry"] || [kind isEqualToString:@"carferry"])
    {
        return [R2RConstants getFerryColor];
    }
    else if ([kind isEqualToString:@"cycle"])
    {
        return [R2RConstants getBikeColor];
    }
    else if ([kind isEqualToString:@"walk"] || [kind isEqualToString:@"animal"] || [kind isEqualToString:@"rideshare"])
    {
        return [R2RConstants getWalkColor];
    }
    return [R2RConstants getUnknownColor];
}


+(NSInteger)getFlightChangeCount:(R2RFlightSegment *)segment
{
    long hops = 5;
    for (R2RFlightItinerary *itinerary in segment.itineraries)
    {
        for (R2RFlightLeg *leg in itinerary.legs)
        {
            if ([leg.hops count] < hops)
            {
                hops = [leg.hops count];
            }
        }
    }
    return (hops - 1); // 1 less change than hops
    
}

@end
