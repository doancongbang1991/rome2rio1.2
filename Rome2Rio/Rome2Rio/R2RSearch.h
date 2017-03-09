//
//  R2RSearch.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 4/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "R2RConnection.h"
#import "R2RSearchResponse.h"
#import "R2RAirport.h"
#import "R2RAirline.h"
#import "R2RAgency.h"
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
#import "R2RCompletionState.h"

@protocol R2RSearchDelegate;

@interface R2RSearch : NSObject

@property (weak, nonatomic) id<R2RSearchDelegate> delegate;
@property (strong, nonatomic) R2RSearchResponse *searchResponse;
@property (nonatomic) R2RCompletionState responseCompletionState;
@property (strong, nonatomic) NSString *responseMessage;

- (id) initWithSearch:(NSString *)oName dName:(NSString *)dName oPos:(NSString *)oPos dPos:(NSString *)dPos oKind:(NSString *)oKind dKind:(NSString *)dKind oCode:(NSString *)oCode dCode:(NSString *)dCode delegate:(id<R2RSearchDelegate>)r2rSearchDelegate;

-(void) sendAsynchronousRequest;

@end

@protocol R2RSearchDelegate <NSObject>

-(void) searchDidFinish: (R2RSearch *) search;

@end
