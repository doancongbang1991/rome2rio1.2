//
//  R2RMapHelper.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 17/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RMapHelper.h"
#import "R2RSegmentHelper.h"
#import "R2RFlightSegment.h"
#import "R2RFlightItinerary.h"
#import "R2RFlightLeg.h"
#import "R2RFlightHop.h"
#import "R2RTransitSegment.h"
#import "R2RWalkDriveSegment.h"

#import "R2RConstants.h"
#import "R2RPath.h"
#import "R2RPathEncoder.h"

#import "R2RPressAnnotationView.h"


@interface R2RMapHelper()

@property (strong, nonatomic) R2RSearchStore *dataStore;

@end

@implementation R2RMapHelper

-(id)initWithData:(R2RSearchStore *)dataStore
{
    self = [super init];
    if (self)
    {
        self.dataStore = dataStore;
    }
    return self;
}

-(MKMapRect)getSegmentBounds:(id)segment
{
    MKMapRect rect = MKMapRectNull;
        
    MKMapPoint sPoint = MKMapPointFromPosition([R2RSegmentHelper getSegmentSPos:segment store:self.dataStore]);
    rect = MKMapRectGrow(rect, sPoint);
    
    MKMapPoint tPoint = MKMapPointFromPosition([R2RSegmentHelper getSegmentTPos:segment store:self.dataStore]);
    rect = MKMapRectGrow(rect, tPoint);
    
    NSString *pathString = [R2RSegmentHelper getSegmentPath:segment];
    if (pathString.length > 0)
    {
        R2RPath *path = [R2RPathEncoder decode:pathString];
        
        for (R2RPosition *pos in path.positions)
        {
            MKMapPoint point = MKMapPointFromPosition(pos);
            rect = MKMapRectGrow(rect, point);
        }
    }
    
    return rect;
}

-(NSString *) getNameFromPlacemarkImpl:(CLPlacemark *) placemark showName:(bool)showName showSubLocality:(bool)showSubLocality showLocality:(bool)showLocality showAdministrativeArea:(bool)showAdministrativeArea showCountry:(bool)showCountry location:(CLLocation *) location
{
    NSMutableArray *names = [[NSMutableArray alloc] init];
    
    if (showName && placemark.name) [names addObject:placemark.name];
    if (showSubLocality && placemark.subLocality && [self shouldShowSubLocality:placemark location:location]) [names addObject:placemark.subLocality];
    if (showLocality && placemark.locality && [self shouldShowLocality:placemark]) [names addObject:placemark.locality];
    if (showAdministrativeArea && placemark.subAdministrativeArea && [self shouldShowSubAdministrative:placemark]) [names addObject:placemark.subAdministrativeArea];
    if (showAdministrativeArea && placemark.administrativeArea && [self shouldShowAdministrative:placemark]) [names addObject:placemark.administrativeArea];
    if (showCountry && placemark.country && [self shouldShowCountry:placemark])
    {
        [names addObject:placemark.country];
    }

    NSMutableString *fullName = [[NSMutableString alloc] init];
    
    for (NSString *name in names)
    {
        [fullName appendString:name];
        if (name != [names lastObject])
        {
            [fullName appendString:@", "];
        }
    }
    
    return fullName;
}

-(NSString *) getVerySpecificLongName:(CLPlacemark *) placemark location:(CLLocation *)location
{
    NSString *name = [self getNameFromPlacemarkImpl:placemark showName:YES showSubLocality:NO showLocality:YES showAdministrativeArea:YES showCountry:YES location:location];
    
    // if name does not match paramaters just return the given name
    if ([name length] == 0) name = placemark.name;
    
    return name;
}

-(NSString *) getLocalityLongName: (CLPlacemark *) placemark location:(CLLocation *)location
{
    NSString *name = [self getNameFromPlacemarkImpl:placemark showName:NO showSubLocality:YES showLocality:YES showAdministrativeArea:YES showCountry:YES location:location];
    
    // if name does not match paramaters just return the given name
    if ([name length] == 0) name = placemark.name;
    
    return name;
}

-(NSString *) getAdministrativeAreaLongName: (CLPlacemark *) placemark location:(CLLocation *)location
{
    NSString *name = [self getNameFromPlacemarkImpl:placemark showName:NO showSubLocality:NO showLocality:NO showAdministrativeArea:YES showCountry:YES location:location];
    
    // if name does not match paramaters just return the given name
    if ([name length] == 0) name = placemark.name;
    
    return name;
}

-(NSString *) getCountryName: (CLPlacemark *) placemark location:(CLLocation *)location
{
    NSString *name = [self getNameFromPlacemarkImpl:placemark showName:NO showSubLocality:NO showLocality:NO showAdministrativeArea:NO showCountry:YES location:location];
    
    // if name does not match paramaters just return the given name
    if ([name length] == 0) name = placemark.name;
    
    return name;
}

-(NSString *)getVerySpecificShortName:(CLPlacemark *)placemark location:(CLLocation *)location
{
    return placemark.name;
}

-(NSString *)getLocalityShortName:(CLPlacemark *)placemark location:(CLLocation *)location
{
    NSString *name = [[NSString alloc] init];
    
    if (location.horizontalAccuracy < 500)
    {
        name = [self getNameFromPlacemarkImpl:placemark showName:NO showSubLocality:YES showLocality:NO showAdministrativeArea:NO showCountry:NO location:location];
    }
    
    if ([name length] == 0 || location.horizontalAccuracy >= 500)
    {
        name = [self getNameFromPlacemarkImpl:placemark showName:NO showSubLocality:NO showLocality:YES showAdministrativeArea:NO showCountry:NO location:location];
    }
    
    // if name does not match paramaters get the next highest name
    if ([name length] == 0) name = [self getAdministrativeAreaLongName:placemark location:location];
    
    return name;
}

-(NSString *)getAdministrativeAreaShortName:(CLPlacemark *)placemark location:(CLLocation *)location
{
    NSString *name = [self getNameFromPlacemarkImpl:placemark showName:NO showSubLocality:NO showLocality:NO showAdministrativeArea:YES showCountry:NO location:location];
    
    // if name does not match paramaters get the next highest name
    if ([name length] == 0) name = [self getCountryName:placemark location:location];
    
    return name;
}

-(bool) shouldShowSubLocality:(CLPlacemark *)placemark location:(CLLocation *)location
{
    // never show subLocality in Australia (while results return "address city suburb")
    if ([placemark.ISOcountryCode isEqualToString:@"AU"])
    {
        return NO;
    }
    
    R2RLog(@"%f",location.horizontalAccuracy);
    
    if ([placemark.ISOcountryCode isEqualToString:@"US"] && location.horizontalAccuracy > 100 && location.horizontalAccuracy <= 500) return YES;
    
    if ([placemark.ISOcountryCode isEqualToString:@"CA"] && location.horizontalAccuracy > 100 && location.horizontalAccuracy <= 500) return YES;
    
    // display subLocality if high accuracy (but not for postal address formats, ie showSubLocality in getNameFromPlacemarkImpl should be NO)
    if (location.horizontalAccuracy > 100 && location.horizontalAccuracy <= 500) return YES;
    
    //default
    return NO;
}

-(bool) shouldShowLocality:(CLPlacemark *)placemark
{
    if ([placemark.ISOcountryCode isEqualToString:@"AU"])
    {
        return YES;
    }
    
    if ([placemark.ISOcountryCode isEqualToString:@"US"]) return YES;
    
    if ([placemark.ISOcountryCode isEqualToString:@"CA"]) return YES;
    
    //default
    return YES;
}

-(bool) shouldShowSubAdministrative:(CLPlacemark *)placemark
{
    if ([placemark.ISOcountryCode isEqualToString:@"AU"]) return NO;

    if ([placemark.ISOcountryCode isEqualToString:@"US"]) return NO;
    
    if ([placemark.ISOcountryCode isEqualToString:@"CA"]) return NO;
    
    //default
    return NO;
}

-(bool) shouldShowAdministrative:(CLPlacemark *)placemark
{
    if ([placemark.ISOcountryCode isEqualToString:@"AU"]) return YES;
    
    if ([placemark.ISOcountryCode isEqualToString:@"US"]) return YES;

    if ([placemark.ISOcountryCode isEqualToString:@"CA"]) return YES;

    //default
    return YES;
}

-(bool) shouldShowCountry:(CLPlacemark *)placemark
{
    return YES;
}


static MKMapPoint MKMapPointFromPosition(R2RPosition *pos)
{
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(pos.lat, pos.lng);
    MKMapPoint mapPoint = MKMapPointForCoordinate(coord);
    
    return mapPoint;
}

static MKMapRect MKMapRectGrow(MKMapRect rect, MKMapPoint point)
{
    MKMapRect pointRect = MKMapRectMake(point.x, point.y, 0, 0);
    
    rect = MKMapRectUnion(rect, pointRect);
    
    return rect;
}

//return an array containing a polyline for each hop
-(NSArray *) getPolylines:(id) segment;
{
    
    if([segment isKindOfClass:[R2RWalkDriveSegment class]])
    {
        return [self getWalkDriveSegmentPolylines:segment];
    }
    else if([segment isKindOfClass:[R2RTransitSegment class]])
    {
        return [self getTransitSegmentPolylines:segment];
    }
    else if([segment isKindOfClass:[R2RFlightSegment class]])
    {
        return  [self getFlightSegmentPolylines:segment];
    }
    else
    {
        return nil;
    }
}

-(NSArray *) getFlightSegmentPolylines: (R2RFlightSegment *) segment
{
    R2RFlightItinerary *itinerary = [segment.itineraries objectAtIndex:0];
    R2RFlightLeg *leg = [itinerary.legs objectAtIndex:0];
    
    //TODO add geodesic Interpolation to flight path
    // for now there is just straight lines between stops
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (R2RFlightHop *hop in leg.hops)
    {
        R2RAirport *sAirport = [self.dataStore getAirport:hop.sCode];
        CLLocationCoordinate2D sPos = CLLocationCoordinate2DMake(sAirport.pos.lat, sAirport.pos.lng);
        
        R2RAirport *tAirport = [self.dataStore getAirport:hop.tCode];
        CLLocationCoordinate2D tPos = CLLocationCoordinate2DMake(tAirport.pos.lat, tAirport.pos.lng);
        
        if ((tPos.longitude - sPos.longitude) > 180 || (tPos.longitude - sPos.longitude) < -180)
        {
            MKMapPoint points[2];
            CLLocationCoordinate2D mPos;
            
            // add polyline for source to edge of map
            mPos.latitude = (tPos.latitude + sPos.latitude)/2;
            mPos.longitude = (sPos.longitude < 0) ? -180.0f : 180.0f;
            
            points[0] = MKMapPointForCoordinate(sPos);
            points[1] = MKMapPointForCoordinate(mPos);
            
            R2RSegmentPolyline *polyline = [R2RSegmentPolyline polylineWithPoints:points count:2];
            polyline.subkind = [R2RSegmentHelper getSegmentSubkind:segment];
            [array addObject:polyline];
            
            // add polyline for edge of map to target
            mPos.longitude = -mPos.longitude;
            
            points[0] = MKMapPointForCoordinate(mPos);
            points[1] = MKMapPointForCoordinate(tPos);
            
            polyline = [R2RSegmentPolyline polylineWithPoints:points count:2];
            polyline.subkind = [R2RSegmentHelper getSegmentSubkind:segment];
            [array addObject:polyline];
        }
        else
        {
            MKMapPoint points[2];
            points[0] = MKMapPointForCoordinate(sPos);
            points[1] = MKMapPointForCoordinate(tPos);
            
            R2RSegmentPolyline *polyline = [R2RSegmentPolyline polylineWithPoints:points count:2];
            polyline.subkind = [R2RSegmentHelper getSegmentSubkind:segment];
            [array addObject:polyline];
        }
    }
    
    return array;
}

-(NSArray *) getTransitSegmentPolylines: (R2RTransitSegment *) segment
{
    R2RPath *path = [R2RPathEncoder decode:segment.path];
    
    MKMapPoint points[[path.positions count]];
    NSUInteger count = 0;
    
    for (R2RPosition *pos in path.positions)
    {
        points[count++] = MKMapPointFromPosition(pos);
    }
    
    R2RSegmentPolyline *polyline = [R2RSegmentPolyline polylineWithPoints:points count:count];
    polyline.subkind = [R2RSegmentHelper getSegmentSubkind:segment];
    
    NSArray *array = [[NSArray alloc] initWithObjects:polyline, nil];
    
    return array;
}

-(NSArray *) getWalkDriveSegmentPolylines:(R2RWalkDriveSegment *) segment
{
    R2RPath *path = [R2RPathEncoder decode:segment.path];
    
    MKMapPoint points[[path.positions count]];
    NSUInteger count = 0;
    
    for (R2RPosition *pos in path.positions)
    {
        points[count++] = MKMapPointFromPosition(pos);
    }
    
    R2RSegmentPolyline *polyline = [R2RSegmentPolyline polylineWithPoints:points count:count];
    polyline.subkind = [R2RSegmentHelper getSegmentSubkind:segment];
    
    NSArray *array = [[NSArray alloc] initWithObjects:polyline, nil];
    
    return array;
}


-(id)getPolylineView:(R2RSegmentPolyline *)segmentPolyline
{
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:segmentPolyline];
    
    UIColor *color = [R2RSegmentHelper getSegmentColorWithKind:segmentPolyline.subkind];
    
    polylineView.strokeColor = [color colorWithAlphaComponent:0.8];
    
    if ([[UIScreen mainScreen] scale] < 2.0)
        polylineView.lineWidth = 5;
    else
        polylineView.lineWidth = 10;
    
    return polylineView;
}

-(id)getAnnotationView:(MKMapView *)mapView annotation:(R2RAnnotation *)annotation
{
    MKAnnotationView *annotationView = nil;
  
    if (annotation.annotationType == r2rAnnotationTypeStop)
    {
        annotationView = [self getStopAnnotationView:mapView annotation:annotation];
    }
    else if (annotation.annotationType == r2rAnnotationTypeHop)
    {
        annotationView = [self getHopAnnotationView:mapView annotation:annotation];
    }
    else if (annotation.annotationType == r2rAnnotationTypeFrom)
    {
        annotationView = [self getFromAnnotationView:mapView annotation:annotation];
    }
    else if (annotation.annotationType == r2rAnnotationTypeTo)
    {
        annotationView = [self getToAnnotationView:mapView annotation:annotation];
    }
    else if (annotation.annotationType == r2rAnnotationTypePress)
    {
        annotationView = [self getPressAnnotationView:mapView annotation:annotation];
    }
    else if (annotation.annotationType == r2rAnnotationTypeMyLocation)
    {
        annotationView = [self getMyLocationAnnotationView:mapView annotation:annotation];
    }

    return annotationView;
}

-(MKAnnotationView *) getStopAnnotationView:(MKMapView *)mapView annotation:(R2RAnnotation *)annotation
{
    NSString *identifier = @"R2RStopAnnotation";
    
    MKAnnotationView *annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        
        CGRect hopIconRect = [R2RConstants getHopIconRect];
        
        R2RSprite *sprite = [[R2RSprite alloc] initWithPath:nil :hopIconRect.origin :hopIconRect.size];
        
        UIImage *image = [sprite getSprite:[UIImage imageNamed:[R2RConstants getIconSpriteFileName]]];
        
        UIImage *smallerImage = [UIImage imageWithCGImage:image.CGImage scale:2.0 orientation:image.imageOrientation];
        annotationView.image = smallerImage;
//        annotationView.image = image;
        
        if ([annotation.title length] > 0)
        {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
            [button setTitle:@"🔍" forState:UIControlStateNormal];
            annotationView.rightCalloutAccessoryView = button;
        }
    }
    return annotationView;
}

-(MKAnnotationView *) getHopAnnotationView:(MKMapView *)mapView annotation:(R2RAnnotation *)annotation
{
    NSString *identifier = @"R2RHopAnnotation";
    
    MKAnnotationView *annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        
        CGRect hopIconRect = [R2RConstants getHopIconRect];
        
        R2RSprite *sprite = [[R2RSprite alloc] initWithPath:nil :hopIconRect.origin :hopIconRect.size];
        
        UIImage *image = [sprite getSprite:[UIImage imageNamed:[R2RConstants getIconSpriteFileName]]];
        
        UIImage *smallerImage = [UIImage imageWithCGImage:image.CGImage scale:2.0 orientation:image.imageOrientation];
        annotationView.image = smallerImage;
        
//        annotationView.image = image;
        
        if ([annotation.title length] > 0)
        {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
            [button setTitle:@"🔍" forState:UIControlStateNormal];
            annotationView.rightCalloutAccessoryView = button;
        }
    }
    return annotationView;
}

-(MKAnnotationView *) getFromAnnotationView:(MKMapView *)mapView annotation:(R2RAnnotation *)annotation
{
    NSString *identifier = @"R2RFromAnnotation";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (annotationView == nil)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.pinColor = MKPinAnnotationColorGreen;
        [annotationView setDraggable:YES];
        
        if ([annotationView.annotation.title length] > 0)
        {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
            [button setTitle:@"🔍" forState:UIControlStateNormal];
            annotationView.rightCalloutAccessoryView = button;
        }
    }
    return annotationView;
}

-(MKAnnotationView *) getToAnnotationView:(MKMapView *)mapView annotation:(R2RAnnotation *)annotation
{
    NSString *identifier = @"R2RToAnnotation";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (annotationView == nil)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.pinColor = MKPinAnnotationColorRed;
        [annotationView setDraggable:YES];
        
        if ([annotationView.annotation.title length] > 0)
        {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
            [button setTitle:@"🔍" forState:UIControlStateNormal];
            annotationView.rightCalloutAccessoryView = button;
        }
    }
    return annotationView;
}

-(MKAnnotationView *) getPressAnnotationView:(MKMapView *)mapView annotation:(R2RAnnotation *)annotation
{
    NSString *identifier = @"R2RPressAnnotation";

    R2RPressAnnotationView *annotationView = (R2RPressAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!annotationView)
    {
        annotationView = [[R2RPressAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    
    return annotationView;
}

-(MKAnnotationView *) getMyLocationAnnotationView:(MKMapView *)mapView annotation:(R2RAnnotation *)annotation
{
    NSString *identifier = @"R2RMyLocation";
    
    MKAnnotationView *annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        
        CGRect hopIconRect = [R2RConstants getMyLocationIconRect];
        
        R2RSprite *sprite = [[R2RSprite alloc] initWithPath:nil :hopIconRect.origin :hopIconRect.size];
        
        UIImage *image = [sprite getSprite:[UIImage imageNamed:[R2RConstants getMyLocationSpriteFileName]]];

//        annotationView.image = image;
        
        UIImage *smallerImage = [UIImage imageWithCGImage:image.CGImage scale:2.0 orientation:image.imageOrientation];
        annotationView.image = smallerImage;
    }

    return annotationView;
}

-(NSArray *)getRouteStopAnnotations:(R2RRoute *)route
{
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    for (R2RStop *stop in route.stops)
    {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(stop.pos.lat, stop.pos.lng);
        R2RAnnotation *annotation = nil;
        if (stop == [route.stops objectAtIndex:0])
        {
            annotation = [[R2RAnnotation alloc] initWithName:stop.name kind:stop.kind coordinate:coord annotationType:r2rAnnotationTypeFrom];
        }
        else if (stop == [route.stops lastObject])
        {
            annotation = [[R2RAnnotation alloc] initWithName:stop.name kind:stop.kind coordinate:coord annotationType:r2rAnnotationTypeTo];
        }
        else
        {
            annotation = [[R2RAnnotation alloc] initWithName:stop.name kind:stop.kind coordinate:coord annotationType:r2rAnnotationTypeStop];
        }
        [annotations addObject:annotation];
    }
    
    return annotations;
}

-(NSArray *) getRouteHopAnnotations:(R2RRoute *)route
{
    NSMutableArray *hopAnnotations = [[NSMutableArray alloc] init];
    
    for (id segment in route.segments)
    {
        if([segment isKindOfClass:[R2RWalkDriveSegment class]])
        {
            [self getWalkDriveHopAnnotations:hopAnnotations segment:segment];
        }
        else if([segment isKindOfClass:[R2RTransitSegment class]])
        {
            [self getTransitHopAnnotations:hopAnnotations segment:segment];
        }
        else if([segment isKindOfClass:[R2RFlightSegment class]])
        {
            [self getFlightHopAnnotations:hopAnnotations segment:segment];
        }
    }
    
    return hopAnnotations;
}

-(void) getWalkDriveHopAnnotations:(NSMutableArray *) hopAnnotations segment:(R2RTransitSegment *)segment
{
    // no annotations
}

-(void) getTransitHopAnnotations:(NSMutableArray *)hopAnnotations segment:(R2RTransitSegment *)segment
{
    R2RTransitItinerary *itinerary = [segment.itineraries objectAtIndex:0];
    for (R2RTransitLeg *leg in itinerary.legs)
    {
        for (R2RTransitHop *hop in leg.hops)
        {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(hop.sPos.lat, hop.sPos.lng);
            R2RAnnotation *annotation = [[R2RAnnotation alloc] initWithName:hop.sName kind:nil coordinate:coord annotationType:r2rAnnotationTypeHop];
            
            [hopAnnotations addObject:annotation];
        }
    }
}

-(void) getFlightHopAnnotations:(NSMutableArray *) hopAnnotations segment:(R2RTransitSegment *)segment
{
    R2RFlightItinerary *itinerary = [segment.itineraries objectAtIndex:0];
    R2RFlightLeg *leg = [itinerary.legs objectAtIndex:0];
    
    for (R2RFlightHop *hop in leg.hops)
    {
        R2RAirport *airport = [self.dataStore getAirport:hop.sCode];
        if (airport == nil) continue;
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(airport.pos.lat, airport.pos.lng);
        R2RAnnotation *annotation = [[R2RAnnotation alloc] initWithName:airport.name kind:nil coordinate:coord annotationType:r2rAnnotationTypeHop];
        
        [hopAnnotations addObject:annotation];
    }
}

-(NSArray *)filterHopAnnotations :(NSArray *)hopAnnotations stopAnnotations:(NSArray *)stopAnnotations regionSpan:(MKCoordinateSpan) span
{
    float latDelta=span.latitudeDelta/10.0;
    float longDelta=span.longitudeDelta/10.0;
    
    NSMutableArray *hopsToShow=[[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSInteger i = 0; i < [hopAnnotations count]; i++)
    {
        R2RAnnotation *checkingLocation=[hopAnnotations objectAtIndex:i];
        CLLocationDegrees latitude = checkingLocation.coordinate.latitude;
        CLLocationDegrees longitude = checkingLocation.coordinate.longitude;
        
        bool found=FALSE;
        
        for (R2RAnnotation *stopAnnotation in stopAnnotations)
        {
            if(fabs(stopAnnotation.coordinate.latitude-latitude) < latDelta &&
               fabs(stopAnnotation.coordinate.longitude-longitude) <longDelta )
            {
                found=TRUE;
                break;
            }
        }
        for (R2RAnnotation *hopAnnotation in hopsToShow)
        {
            if(fabs(hopAnnotation.coordinate.latitude-latitude) < latDelta &&
               fabs(hopAnnotation.coordinate.longitude-longitude) <longDelta )
            {
                found=TRUE;
                break;
            }
        }
        if (!found)
        {
            [hopsToShow addObject:checkingLocation];
        }
        
    }
    
    return hopsToShow;
}

-(NSArray *) removeAnnotations :(NSArray *) firstArray :(NSArray *) secondArray
{
    NSMutableArray *result = [NSMutableArray arrayWithArray:firstArray];
   
    for (NSInteger i = [firstArray count] - 1; i >= 0; i--)
    {
        for (NSInteger j = [secondArray count] - 1; j >= 0; j--)
        {
            if ([self areHopAnnotationsEquivalent:[firstArray objectAtIndex:i] :[secondArray objectAtIndex:j]])
            {
                [result removeObjectAtIndex:i];
                break;
            }
        }
    }
    
    return result;
}

-(BOOL) areHopAnnotationsEquivalent :(R2RAnnotation *) first :(R2RAnnotation *) second
{
    return ([first.name isEqualToString:second.name] &&
            first.coordinate.latitude == second.coordinate.latitude &&
            first.coordinate.longitude == second.coordinate.longitude);
}

@end


@implementation R2RSegmentPolyline

@synthesize subkind;

@end
