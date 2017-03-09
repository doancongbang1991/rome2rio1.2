//
//  R2RPrintSearch.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 5/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RPrintSearch.h"

#import "R2RAirport.h"
#import "R2RAirline.h"
#import "R2RRoute.h"
#import "R2RWalkDriveSegment.h"
#import "R2RTransitSegment.h"
#import "R2RTransitItinerary.h"
#import "R2RTransitLeg.h"
#import "R2RTransitHop.h"
#import "R2RTransitLine.h"
#import "R2RFlightSegment.h"
#import "R2RFlightItinerary.h"
#import "R2RFlightLeg.h"
#import "R2RFlightHop.h"
#import "R2RFlightTicketSet.h"
#import "R2RFlightTicket.h"
#import "R2RPosition.h"
#import "R2RStop.h"

@implementation R2RPrintSearch

-(void) printSearchData:(R2RSearchResponse *)searchData
{
    for (R2RAirline *airline in searchData.airlines)
    {
        R2RLog(@"Airline\t%@\t%@\t%@", airline.name, airline.code, airline.url);
    }
    
    for (R2RAirport *airport in searchData.airports)
    {
        R2RLog(@"Airport\t%@\t%@\t%f\t%f", airport.name, airport.code, airport.pos.lat, airport.pos.lng);
    }
    
    for (R2RRoute *route in searchData.routes)
    {
        [self printRoute:route];
    }
}

-(void) printRoute:(R2RRoute *) route
{
    R2RLog(@"Route\t%@\t%f\t%f", route.name, route.distance, route.duration);
    
    for (R2RStop *stop in route.stops)
    {
        [self printStop:stop];
    }
    
    for (id segment in route.segments)
    {
        R2RLog(@"%@", [segment class]);
        
        if([segment isKindOfClass:[R2RWalkDriveSegment class]])
        {
            [self printWalkDriveSegment:segment];
        }
        
        if([segment isKindOfClass:[R2RTransitSegment class]])
        {
            [self printTransitSegment:segment];
        }
        
        if([segment isKindOfClass:[R2RFlightSegment class]])
        {
            [self printFlightSegment:segment];
        }
    }    
}

-(void) printStop:(R2RStop*) stop
{
    R2RLog(@"Stop\t%@\t%f\t%f\t%@\t%@", stop.name, stop.pos.lat, stop.pos.lng, stop.kind, stop.code);
}

-(void) printWalkDriveSegment:(R2RWalkDriveSegment*) segment
{
    R2RLog(@"WalkDrive\t%@\t%f\t%f\t%@\t%f\t%f\t%@\t%f\t%f\t", segment.kind, segment.distance, segment.duration, segment.sName, segment.sPos.lat, segment.sPos.lng, segment.tName, segment.tPos.lat, segment.tPos.lng);
}

-(void) printTransitSegment:(R2RTransitSegment*) segment
{
    R2RLog(@"Tranist\t%@\t%f\t%f\t%@\t%f\t%f\t%@\t%f\t%f\t", segment.kind, segment.distance, segment.duration, segment.sName, segment.sPos.lat, segment.sPos.lng, segment.tName, segment.tPos.lat, segment.tPos.lng);
    
    for (R2RTransitItinerary *itinerary in segment.itineraries)
    {
        [self printTransitItinerary: itinerary];
    }
}

-(void)  printTransitItinerary:(R2RTransitItinerary*) itinerary
{
    for (R2RTransitLeg *leg in itinerary.legs)
    {
        [self printTransitLeg:leg];
    }
}

-(void) printTransitLeg:(R2RTransitLeg*) leg
{
    R2RLog(@"%@\t%@", leg.url, leg.host);
    
    for (R2RTransitHop *hop in leg.hops)
    {
        [self printTransitHop:hop];
    }
}

-(void) printTransitHop:(R2RTransitHop*) hop
{
    R2RLog(@"TranistHop\t%f\t%f\t%@\t%@\t%@\t%@", hop.duration, hop.frequency, hop.sName, hop.sPos, hop.tName, hop.tPos);
    
    for (R2RTransitLine *line in hop.lines)
    {
        [self printTransitLine:line];
    }
}

-(void) printTransitLine:(R2RTransitLine*) line 
{
    R2RLog(@"TransitLine\t%@\t%@\t%f\t%@\t%@", line.agency, line.code, line.frequency, line.name, line.vehicle);
}

-(void) printFlightSegment:(R2RFlightSegment*) segment
{
    R2RLog(@"Flight\t%@\t%f\t%f\t%@\t%@\t", segment.kind, segment.distance, segment.duration, segment.sCode, segment.tCode);
    
    for (R2RFlightItinerary *itinerary in segment.itineraries)
    {
        [self printFlightItinerary:itinerary];
    }
}

-(void) printFlightItinerary:(R2RFlightItinerary*) itinerary
{
    for (R2RFlightLeg *leg in itinerary.legs)
    {
        [self printFlightLeg:leg];
    }
    for (R2RFlightTicketSet *ticketSet in itinerary.ticketSets)
    {
        [self printFlightTicketSets:ticketSet];
    }
}

-(void) printFlightLeg:(R2RFlightLeg*) leg
{
    for (R2RFlightHop *hop in leg.hops)
    {
        [self printFlightHop:hop];
    }
}

-(void) printFlightHop:(R2RFlightHop*) hop
{
    R2RLog(@"Flight Hop\t%@\t%@\t%@\t%@\t%@\t%@\t%f\t%d\t%f\t%d", hop.sCode, hop.tCode, hop.sTime, hop.tTime, hop.airline, hop.flight, hop.duration, hop.dayChange, hop.lDuration, hop.lDayChange);
}

-(void) printFlightTicketSets:(R2RFlightTicketSet*) ticketSet
{
    for (R2RFlightTicket* ticket in ticketSet.tickets)
    {
        R2RLog(@"Flight Tickets\t%@\t%@\t%@\t%f\t%@\t%@\t%@\t", ticketSet.sCode, ticketSet.tCode, ticket.name, ticket.price, ticket.currency, ticket.message, ticket.url);
    }
}

@end
