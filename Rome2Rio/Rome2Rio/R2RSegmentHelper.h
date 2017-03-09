//
//  R2RSegmentHandler.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 26/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "R2RSprite.h"
#import "R2RSearchStore.h"

#import "R2RWalkDriveSegment.h"
#import "R2RTransitSegment.h"
#import "R2RTransitItinerary.h"
#import "R2RTransitLeg.h"
#import "R2RTransitHop.h"
#import "R2RFlightSegment.h"
#import "R2RFlightItinerary.h"
#import "R2RFlightLeg.h"
#import "R2RFlightHop.h"
#import "R2RFlightTicketSet.h"
#import "R2RFlightTicket.h"

@interface R2RSegmentHelper : NSObject

+(R2RSprite *) getRouteSprite:(NSString *) kind;
+(R2RSprite *) getConnectionSprite: (id) segment;
+(R2RSprite *) getExternalLinkWhiteSprite;
+(R2RSprite *) getExternalLinkPinkSprite;
+(UIColor *) getSegmentColorWithKind: (NSString *) kind;

+(BOOL) getSegmentIsMajor:(id) segment;
+(NSString*) getSegmentKind:(id) segment;
+(NSString*) getSegmentSubkind:(id) segment;
+(NSString*) getSegmentPath:(id) segment;
+(R2RPosition *) getSegmentSPos:(id) segment store:(R2RSearchStore*) dataStore;
+(R2RPosition *) getSegmentTPos:(id) segment store:(R2RSearchStore*) dataStore;
+(R2RIndicativePrice *) getSegmentIndicativePrice:(id) segment;

+(NSInteger) getTransitChangeCount: (R2RTransitSegment *) segment;
+(float) getTransitFrequency: (R2RTransitSegment *)segment;
+(NSString *) getTransitLine: (R2RTransitSegment *)segment;

+(NSInteger) getFlightChangeCount: (R2RFlightSegment *) segment;

@end
