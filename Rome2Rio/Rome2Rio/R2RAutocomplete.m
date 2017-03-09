//
//  R2RAutocomplete.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 31/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RAutocomplete.h"
#import "R2RMapHelper.h"
#import "R2RConstants.h"
#import "R2RKeys.h"

@interface R2RAutocomplete() <R2RConnectionDelegate>

@property (strong, nonatomic) R2RConnection *r2rConnection;

@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSString *languageCode;

@property (nonatomic) NSInteger retryCount;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

@end

@implementation R2RAutocomplete

@synthesize geocodeResponse, responseCompletionState, responseMessage, query = _query;
@synthesize delegate = _delegate;

-(id) initWithQuery:(NSString *)query :(NSString *)countryCode :(NSString *)languageCode delegate:(id<R2RAutocompleteDelegate>)delegate
{
    self = [super init];
    
    if (self != nil)
    {
        self.retryCount = 0;
        self.delegate = delegate;
        self.query = query;
        self.countryCode = countryCode;
        self.languageCode = languageCode;
    }
    
    return self;
}

-(id) initWithQueryString:(NSString *)initSearchString delegate:(id<R2RAutocompleteDelegate>)autocompleteDelegate
{
    self = [super init];
    
    if (self != nil)
    {
        self.retryCount = 0;
        self.delegate = autocompleteDelegate;
        self.query = initSearchString;
    }
    return self;
}


-(void) sendAsynchronousRequest
{
    NSMutableString *geoCoderString = [[NSMutableString alloc] init];
    
    NSString *appKey = [R2RKeys getAppKey];
    
#if DEBUG
    [geoCoderString appendFormat:@"https://working.rome2rio.com/api/1.2/json/Autocomplete?key=%@&query=%@", appKey, self.query];
#else
    [geoCoderString appendFormat:@"https://ios.rome2rio.com/api/1.2/json/Autocomplete?key=%@&query=%@", appKey, self.query];
#endif
    
    if ([self.countryCode length] > 0)
    {
        [geoCoderString appendFormat:@"&countryCode=%@", self.countryCode];
    }
    
    if ([self.languageCode length] > 0)
    {
        [geoCoderString appendFormat:@"&languageCode=%@", self.languageCode];
    }
    
    NSString *userId = [R2RConstants getUserId];
    
    if ([userId length] > 0)
    {
        [geoCoderString appendFormat:@"&uid=%@",userId];
    }
    
    NSString *geoCoderEncoded = [geoCoderString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *getCoderUrl =  [NSURL URLWithString:geoCoderEncoded];
    
    self.r2rConnection = [[R2RConnection alloc] initWithConnectionUrl:getCoderUrl delegate:self];
    
    self.responseCompletionState = r2rCompletionStateResolving;
    
    [self performSelector:@selector(connectionTimeout:) withObject:self.r2rConnection afterDelay:5.0];
}

-(void) parseJson
{
    NSError *error = nil;
    
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:self.r2rConnection.responseData options:kNilOptions error:&error];
    
    self.geocodeResponse = [self parseData:responseData];
}

-(R2RGeocodeResponse*) parseData:(NSDictionary* )responseData
{
    R2RGeocodeResponse *response = [R2RGeocodeResponse alloc];
    
    response.query = [responseData objectForKey:@"query"];
    response.countryCode = [responseData objectForKey:@"countryCode"];
    response.languageCode = [responseData objectForKey:@"languageCode"];
    
    response.places = [self parsePlaces:[responseData objectForKey:@"places"]];

    self.responseCompletionState = r2rCompletionStateResolved;
    self.responseMessage = @"";
    
    return response;
}

-(NSMutableArray*) parsePlaces:( NSArray *) placesResponse
{
    NSMutableArray *places = [[NSMutableArray alloc] initWithCapacity:[placesResponse count]];
    
    for (id placeResponse in placesResponse)
    {
        R2RPlace *place = [self parsePlace:placeResponse];
        [places addObject:place];
    }
    
    return places;
}

-(R2RPlace*) parsePlace:(id) placeResonse
{
    R2RPlace *place = [R2RPlace alloc];
    
    place.longName = [placeResonse objectForKey:@"longName"];
    place.shortName = [placeResonse objectForKey:@"shortName"];
    place.countryCode = [placeResonse objectForKey:@"countryCode"];
    place.countryName = [placeResonse objectForKey:@"countryName"];
    place.kind = [placeResonse objectForKey:@"kind"];
    place.lat = [[placeResonse objectForKey:@"lat"] floatValue];
    place.lng = [[placeResonse objectForKey:@"lng"] floatValue];
    place.rad = [placeResonse objectForKey:@"rad"];
    place.regionCode = [placeResonse objectForKey:@"regionCode"];
    place.regionName = [placeResonse objectForKey:@"regionName"];
    place.code = ([placeResonse objectForKey:@"code"]) ? [placeResonse objectForKey:@"code"] : nil;
    
    return place;
}

- (void) connectionProcessData:(R2RConnection *) connection
{
    if (self.r2rConnection == connection)
    {
        [self parseJson];
        [[self delegate] autocompleteResolved:self];
    }
}

- (void) connectionError:(R2RConnection *)connection
{
    if (self.r2rConnection == connection)
    {
        if (self.retryCount < 5)
        {
            [self performSelector:@selector(sendAsynchronousRequest) withObject:nil afterDelay:0.5];
            self.retryCount++;
        }
        else
        {
            R2RLog(@"Error\t%@", connection.error.localizedDescription);
            
            self.responseCompletionState = r2rCompletionStateError;
            self.responseMessage = connection.error.localizedDescription;
            
            [[self delegate] autocompleteResolved:self];
        }
    }
}

- (void) connectionTimeout:(R2RConnection *)connection
{
    if (self.r2rConnection == connection)
    {
        if (self.responseCompletionState == r2rCompletionStateResolving)
        {
            R2RLog(@"Timeout"); 
            
            self.responseMessage = NSLocalizedString(@"Server Temporarily Unavailable", nil);
            self.responseCompletionState = r2rCompletionStateError;
            
            [[self delegate] autocompleteResolved:self];
        }
    }
}

-(void)geocodeFallback:(NSString *)query
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:query completionHandler:^(NSArray *placemarks, NSError *error)
     {
         self.geocodeResponse = [[R2RGeocodeResponse alloc] init];
         
         if ([placemarks count] > 0)
         {
//             CLPlacemark *logPlacemark = [placemarks objectAtIndex:0];
//             R2RLog(@"%@\t:\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t%@\t", logPlacemark.name, logPlacemark.subThoroughfare, logPlacemark.thoroughfare, logPlacemark.subLocality, logPlacemark.locality, logPlacemark.subAdministrativeArea, logPlacemark.administrativeArea, logPlacemark.country,logPlacemark.ISOcountryCode);
             
             self.geocodeResponse.places = [[NSMutableArray alloc] init];
             
             for (CLPlacemark *placemark in placemarks)
             {
                 
                 R2RPlace *place = [[R2RPlace alloc] init];
                 
                 NSMutableString *longName = [[NSMutableString alloc] init];
                 NSMutableString *shortName = [[NSMutableString alloc] init];
                 if ([placemark.subThoroughfare length] > 0)
                 {
                     [longName appendFormat:@"%@ ", placemark.subThoroughfare];
                     [shortName appendFormat:@"%@ ", placemark.subThoroughfare];
                 }
                 
                 if ([placemark.thoroughfare length] > 0)
                 {
                     [longName appendFormat:@"%@, ", placemark.thoroughfare];
                     [shortName appendFormat:@"%@", placemark.thoroughfare];
                     place.kind = @":veryspecific";
                 }
                 
                 R2RMapHelper *mapHelper = [[R2RMapHelper alloc] init];
                 
                 if ([placemark.subLocality length] > 0 && [mapHelper shouldShowSubLocality:placemark location:placemark.location])
                 {
                     [longName appendFormat:@"%@, ", placemark.subLocality];
                     if ([place.kind length] == 0)
                         place.kind = @"city";
                     if ([shortName length] == 0)
                         [shortName appendString:placemark.locality];
                 }
                 
                 if ([placemark.locality length] > 0 && ([mapHelper shouldShowLocality:placemark] || [longName length] == 0))
                 {
                     [longName appendFormat:@"%@, ", placemark.locality];
                     if ([place.kind length] == 0)
                         place.kind = @"city";
                     if ([shortName length] == 0)
                         [shortName appendString:placemark.locality];
                 }
                 
                 if ([placemark.subAdministrativeArea length] > 0 && [mapHelper shouldShowSubAdministrative:placemark])
                 {
                     [longName appendFormat:@"%@, ", placemark.subAdministrativeArea];
                     if ([place.kind length] == 0)
                         place.kind = @"state";
                     if ([shortName length] == 0)
                         [shortName appendString:placemark.subAdministrativeArea];
                 }
                 
                 if ([placemark.administrativeArea length] > 0 && [mapHelper shouldShowAdministrative:placemark])
                 {
                     [longName appendFormat:@"%@, ", placemark.administrativeArea];
                     if ([place.kind length] == 0)
                         place.kind = @"state";
                     if ([shortName length] == 0)
                         [shortName appendString:placemark.administrativeArea];
                 }
                 
                 if ([placemark.country length] > 0 && [mapHelper shouldShowCountry:placemark])
                 {
                     [longName appendFormat:@"%@", placemark.country];
                     if ([place.kind length] == 0)
                         place.kind = @"country";
                     if ([shortName length] == 0)
                         [shortName appendString:placemark.country];
                 }
                 
                 place.longName = [NSString stringWithString:longName];
                 place.shortName = [NSString stringWithString:shortName];
                 
                 place.lat = placemark.location.coordinate.latitude;
                 place.lng = placemark.location.coordinate.longitude;
             
                 [self.geocodeResponse.places addObject:place];
                 R2RLog(@"%@", place.longName);
             }
             
             self.responseMessage = @"";
             self.responseCompletionState = r2rCompletionStateResolved;
             
             [[self delegate] autocompleteResolved:self];
         }
         else
         {
             R2RLog(@"error code %ld", (long)error.code);
             switch (error.code)
             {
                 case kCLErrorDenied:
                     self.responseMessage = NSLocalizedString(@"Location services are off", nil);
                     break;
                     
                 case kCLErrorNetwork:
                     self.responseMessage = NSLocalizedString(@"Internet appears to be offline", nil);
                     break;
                     
                 default:
                     self.responseMessage = NSLocalizedString(@"Unable to find location", nil);
                     break;
             }
             
             self.responseCompletionState = r2rCompletionStateLocationNotFound;
             
             [[self delegate] autocompleteResolved:self];
         }
     }];
}

@end
