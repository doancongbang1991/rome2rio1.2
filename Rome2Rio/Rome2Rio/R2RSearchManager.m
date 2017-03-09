//
//  R2RDataManager.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 2/11/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RSearchManager.h"
#import "R2RCompletionState.h"
#import "R2RMapHelper.h"

@interface R2RSearchManager()

typedef enum
{
    r2rSearchManagerStateIdle = 0,
    r2rSearchManagerStateResolvingLocation,
    r2rSearchManagerStateSearching,
} R2RSearchManagerState;

@property R2RSearchManagerState state;

@property (strong, nonatomic) R2RSearch *search;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *bestLocation;

@property (nonatomic) BOOL isLocationManagerResolving;
@property (nonatomic) BOOL fromWantsCurrentLocation;
@property (nonatomic) BOOL toWantsCurrentLocation;
@property (nonatomic) BOOL fromWantsMapLocation;
@property (nonatomic) BOOL toWantsMapLocation;

@end

@implementation R2RSearchManager

@synthesize fromText, toText;

-(void) setFromPlace:(R2RPlace *)fromPlace
{
    self.fromWantsCurrentLocation = NO;
    self.fromWantsMapLocation = NO;
    
    self.searchStore.fromPlace = fromPlace;
    self.searchStore.searchResponse = nil;
    
    if ([self canStartSearch]) [self startSearch];
}

-(void) setToPlace:(R2RPlace *)toPlace
{
    self.toWantsCurrentLocation = NO;
    self.toWantsMapLocation = NO;
    
    self.searchStore.toPlace = toPlace;
    self.searchStore.searchResponse = nil;
    
    if ([self canStartSearch]) [self startSearch];
}

-(void) setFromWithCurrentLocation
{
    [self setFromPlace:nil];
    
    self.fromWantsCurrentLocation = YES;
    [self setStatusMessage:NSLocalizedString(@"Finding Current Location", nil)];
    
    [self startLocationManager];
}

-(void) setToWithCurrentLocation
{
    [self setToPlace:nil];
    
    self.toWantsCurrentLocation = YES;
    [self setStatusMessage:NSLocalizedString(@"Finding Current Location", nil)];
    
    [self startLocationManager];
}

-(void) setFromWithMapLocation:(CLLocationCoordinate2D) coord mapScale:(float) mapScale
{
    [self setFromPlace:nil];
    
    self.fromWantsMapLocation = YES;
    [self setStatusMessage:NSLocalizedString(@"Finding Map Location", nil)];
    
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:coord altitude:0 horizontalAccuracy:mapScale verticalAccuracy:100 timestamp:[NSDate date]];
    [self reverseGeocodeLocation:location fieldType:@"mapFrom"];
}

-(void) setToWithMapLocation:(CLLocationCoordinate2D) coord mapScale:(float) mapScale
{
    [self setToPlace:nil];
    
    self.toWantsMapLocation = YES;
    [self setStatusMessage:NSLocalizedString(@"Finding Map Location", nil)];
    
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:coord altitude:0 horizontalAccuracy:mapScale verticalAccuracy:100 timestamp:[NSDate date]];
    [self reverseGeocodeLocation:location fieldType:@"mapTo"];
}

-(void) setStatusMessage:(NSString *) statusMessage
{
    self.searchStore.statusMessage = statusMessage;
}

-(void) setSearchMessage:(NSString *)searchMessage
{
    self.searchStore.searchMessage = searchMessage;
}

-(void) restartSearch
{
    // restart search. Used if currency changes
    if ([self canStartSearch]) [self startSearch];
}

-(void) restartSearchIfNoResponse
{
    if (!self.searchStore.searchResponse)
    {
        // if no response, not currently searching and can search, start search
        if (self.state != r2rSearchManagerStateSearching && [self canStartSearch]) [self startSearch];
    }
}

-(BOOL) isSearching
{
    return (self.state == r2rSearchManagerStateSearching);
}

-(BOOL) canStartSearch
{
    return (self.searchStore.fromPlace && self.searchStore.toPlace);
}

-(BOOL) canShowSearchResults
{
    //if fromplace is empty and not waiting for a location
    if (!self.searchStore.fromPlace && !self.fromWantsCurrentLocation && !self.fromWantsMapLocation)
//    if (!self.searchStore.fromPlace && self.state == r2rSearchManagerStateIdle)
    {
        [self setStatusMessage:NSLocalizedString(@"Enter Origin", nil)];
        
        return NO;
    }
    
    if (!self.searchStore.toPlace && !self.toWantsCurrentLocation && !self.toWantsMapLocation)
//    if (!self.searchStore.toPlace && self.state == r2rSearchManagerStateIdle)
    {
        [self setStatusMessage:NSLocalizedString(@"Enter Destination", nil)];
        
        return NO;
    }
    
    return YES;
}

- (void) startSearch
{
    self.searchStore.searchResponse = nil;
    
    NSString *oName = self.searchStore.fromPlace.shortName;
    NSString *dName = self.searchStore.toPlace.shortName;
    NSString *oPos = [NSString stringWithFormat:@"%f,%f", self.searchStore.fromPlace.lat, self.searchStore.fromPlace.lng];
    NSString *dPos = [NSString stringWithFormat:@"%f,%f", self.searchStore.toPlace.lat, self.searchStore.toPlace.lng];
    NSString *oKind = self.searchStore.fromPlace.kind;
    NSString *dKind = self.searchStore.toPlace.kind;
    NSString *oCode = self.searchStore.fromPlace.code;
    NSString *dCode = self.searchStore.toPlace.code;
    
    self.search = [[R2RSearch alloc] initWithSearch:oName dName:dName oPos:oPos dPos:dPos oKind:oKind dKind:dKind oCode:oCode dCode:dCode delegate:self];
    
    self.state = r2rSearchManagerStateSearching;
}

- (void) searchDidFinish:(R2RSearch *)search;
{
    if (search == self.search)
    {
        if (self.search.responseCompletionState == r2rCompletionStateResolved)
        {
            self.searchStore.searchResponse = search.searchResponse;
            [self setSearchMessage:@""];
        }
        else
        {
            self.searchStore.searchResponse = nil;
            R2RLog("%@", search.responseMessage);
            [self setSearchMessage:search.responseMessage];
        }
        
        [self loadAirlineImages];
        [self loadAgencyImages];
        
        self.state = r2rSearchManagerStateIdle;
        
    }
}

- (void) startLocationManager
{
    //return if already resolving
    if (self.isLocationManagerResolving) return;

    R2RLog(@"locationManager started");

    self.bestLocation = nil;
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    
    // If location services are disabled we sometimes do not get a didFailWithError callback.
    // Calling it twice seems to fix that
    [self.locationManager startUpdatingLocation];
    
    [self performSelector:@selector(locationManagerTimeout:) withObject:self.locationManager afterDelay:30.0];
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    R2RLog(@"locationManager fail\t%@", error);
    
    // Stop location manager
    [manager stopUpdatingLocation];
    
    // Ignore orphaned callback
    if (manager != self.locationManager) return;
    
    [self locationError:error];
}

- (void)locationManagerTimeout:(CLLocationManager *)manager
{
    // Stop location manager
    [manager stopUpdatingLocation];
    
    // Ignore orphaned callback
    if (manager != self.locationManager) return;
    
    // Fallback bestLocation if available
    if (self.bestLocation)
    {
        [self reverseGeocodeLocationWithManager:manager location:self.bestLocation];
    }
    else
    {
        [self locationError:nil];
    }
}

- (void) locationError:(NSError *) error
{
    R2RLog(@"error code %ld", (long)error.code);
    // Set error status
    switch (error.code)
    {
        case kCLErrorDenied:
            [self setStatusMessage:NSLocalizedString(@"Location services are off", nil)];
            break;
            
        case kCLErrorNetwork:
            [self setStatusMessage:NSLocalizedString(@"Internet appears to be offline", nil)];
            break;
            
        default:
            [self setStatusMessage:NSLocalizedString(@"Unable to find location", nil)];
            break;
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    R2RLog(@"%f\t%f\t%f\t%f\t%f\t%f\t", -[newLocation.timestamp timeIntervalSinceNow], manager.desiredAccuracy, newLocation.horizontalAccuracy, newLocation.verticalAccuracy, newLocation.coordinate.latitude, newLocation.coordinate.longitude);

    if (manager != self.locationManager)
    {
        [manager stopUpdatingLocation];
        return;
    }
    
    [self updateLocation:newLocation];
}

-(void) updateLocation:(CLLocation *) newLocation;
{
    // Initialize bestLocation
    if (!self.bestLocation) self.bestLocation = newLocation;
    
    // Discard locations more than a minute old
    if (-[newLocation.timestamp timeIntervalSinceNow] > 60.0) return;
    
    // Discard location that is less accurate than bestLocation
    if (newLocation.horizontalAccuracy > self.bestLocation.horizontalAccuracy) return;
    
    // Update bestLocation
    self.bestLocation = newLocation;
    
    // If location accuracy within desired limit start reverseGeocode
    if (self.bestLocation.horizontalAccuracy <= 100.0)
    {
        [self.locationManager stopUpdatingLocation];
        
        [self reverseGeocodeLocationWithManager:self.locationManager location:self.bestLocation];
    }
}

- (void)reverseGeocodeLocation:(CLLocation *)location fieldType:(NSString *)fieldType
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if ([placemarks count] > 0)
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             
             [self didFindPlacemark:placemark location:location fieldType:fieldType];
         }
         else
         {
             [self locationError:error];
         }
     }];
}

- (void)reverseGeocodeLocationWithManager:(CLLocationManager *)manager location:(CLLocation *)location
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         // Discard orphaned callback
         if (manager != self.locationManager) return;
         
         if ([placemarks count] > 0)
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             
             [self didFindPlacemark:placemark location:location fieldType:@"currentLocation"];
             self.locationManager = nil;
         }
         else
         {
             [self locationError:error];
         }
     }];
}

- (void)didFindPlacemark:(CLPlacemark *)placemark location:(CLLocation *)location fieldType:(NSString *) fieldType
{
    R2RPlace *place = [[R2RPlace alloc] init];
    
    R2RLog(@"%@\t:%.2f\t\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t", placemark.name, location.horizontalAccuracy, placemark.subThoroughfare, placemark.thoroughfare, placemark.subLocality, placemark.locality, placemark.subAdministrativeArea, placemark.administrativeArea, placemark.country,placemark.ISOcountryCode);
    
    place.lat = location.coordinate.latitude;
    place.lng = location.coordinate.longitude;
    
    R2RMapHelper *mapHelper = [[R2RMapHelper alloc] init];
    
    if (location.horizontalAccuracy <= 100)
    {
        place.kind = @":veryspecific";
        
        if ([fieldType isEqualToString:@"currentLocation"] && [placemark.subThoroughfare length] == 0 && [placemark.thoroughfare length] == 0)
        {
            // if the reverse geocoder did not return an address for current location, display "Current Location"
            place.shortName = [NSString stringWithFormat:@"Current Location, %@", placemark.name];
            place.longName = [NSString stringWithFormat:@"Current Location, %@", placemark.name];
        }
        else
        {
            place.shortName = [mapHelper getVerySpecificShortName:placemark location:location];
            place.longName = [mapHelper getVerySpecificLongName:placemark location:location];
        }
    }
    else if (location.horizontalAccuracy <= 500)
    {
        place.kind = @":specific";
        place.shortName = [mapHelper getLocalityShortName:placemark location:location];
        place.longName = [mapHelper getLocalityLongName:placemark location:location];
    }
    else if (location.horizontalAccuracy <= 5000)
    {
        place.kind = @":notspecific";
        place.shortName = [mapHelper getLocalityShortName:placemark location:location];
        place.longName = [mapHelper getLocalityLongName:placemark location:location];
    }
    else if (location.horizontalAccuracy <= 30000)
    {
        place.kind = @"region";
        place.shortName = [mapHelper getAdministrativeAreaShortName:placemark location:location];
        place.longName = [mapHelper getAdministrativeAreaLongName:placemark location:location];
    }
    else
    {
        place.kind = @"country";
        place.shortName = [mapHelper getCountryName:placemark location:location];
        place.longName = [mapHelper getCountryName:placemark location:location];
    }
    
    
    if (self.fromWantsMapLocation && [fieldType isEqualToString:@"mapFrom"])
    {
        [self setFromPlace:place];
    }
    if (self.toWantsMapLocation && [fieldType isEqualToString:@"mapTo"])
    {
        [self setToPlace:place];
    }
    
    if (self.fromWantsCurrentLocation && [fieldType isEqualToString:@"currentLocation"])
    {
        [self setFromPlace:place];
    }
    if (self.toWantsCurrentLocation && [fieldType isEqualToString:@"currentLocation"])
    {
        [self setToPlace:place];
    }
    R2RLog(@"%@\t:%.2f", place.longName, location.horizontalAccuracy);
}

-(void) loadAirlineImages
{
    for (R2RAirline *airline in self.search.searchResponse.airlines)
    {
        //pre cache airline images.
        [self.searchStore.spriteStore loadImage:airline.iconPath];
    }
}

-(void) loadAgencyImages
{
    for (R2RAgency *agency in self.search.searchResponse.agencies)
    {
        [self.searchStore.spriteStore loadImage:agency.iconPath];
    }
}

@end
