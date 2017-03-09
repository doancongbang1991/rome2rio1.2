//
//  R2RDataManager.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 2/11/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "R2RSearchStore.h"

@interface R2RSearchManager : NSObject <R2RSearchDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) R2RSearchStore *searchStore;

@property (strong, nonatomic) NSString *fromText;
@property (strong, nonatomic) NSString *toText;

-(void) setFromPlace:(R2RPlace *)fromPlace;
-(void) setToPlace:(R2RPlace *)toPlace;

-(void) setFromWithCurrentLocation;
-(void) setToWithCurrentLocation;
-(void) setFromWithMapLocation:(CLLocationCoordinate2D) coord mapScale:(float) mapScale;
-(void) setToWithMapLocation:(CLLocationCoordinate2D) coord mapScale:(float) mapScale;

-(void) setStatusMessage:(NSString *) statusMessage;
-(void) setSearchMessage:(NSString *) searchMessage;

-(BOOL) isSearching;
-(BOOL) canShowSearchResults;

-(void) restartSearch;
-(void) restartSearchIfNoResponse;

@end