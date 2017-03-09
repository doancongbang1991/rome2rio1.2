//
//  R2RDetailViewController.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 30/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "R2RDetailViewController.h"

#import "R2RFlightSegmentViewController.h"
#import "R2RTransitSegmentViewController.h"
#import "R2RWalkDriveSegmentViewController.h"

#import "R2RNameCell.h"
#import "R2RFlightHopCell.h"
#import "R2RTransitHopCell.h"
#import "R2RWalkDriveHopCell.h"

#import "R2RStringFormatter.h"
#import "R2RSegmentHelper.h"
#import "R2RSprite.h"
#import "R2RMapHelper.h"
#import "R2RConstants.h"
#import "R2RPressAnnotationView.h"

@interface R2RDetailViewController ()

@property (strong, nonatomic) R2RAnnotation *pressAnnotation;
@property (nonatomic) CLLocationDegrees zoomLevel;
@property (nonatomic) BOOL isMapZoomedToAnnotation;

@property (nonatomic) bool fromAnnotationDidMove;
@property (nonatomic) bool toAnnotationDidMove;

@property (nonatomic) bool isMapFullSreen;

@end

@implementation R2RDetailViewController

@synthesize route, searchStore, searchManager;

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Route", nil);
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(navigateBack)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [self.searchButton setTitle:NSLocalizedString(@"Search", nil) forState:UIControlStateNormal];
    
    
    [self.view setBackgroundColor:[R2RConstants getBackgroundColor]];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[R2RConstants getBackgroundColor]];
    
    [self.view sendSubviewToBack:self.mapView];

    // set default to show grabBar in footer
    [self setTableFooterWithGrabBar];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showPressAnnotation:)];
    [self.mapView addGestureRecognizer:longPressGesture];
    
    [self configureMap];
    
    //after annotations are initially placed set DidMove to NO so we don't resolve again unless it changes
    self.fromAnnotationDidMove = NO;
    self.toAnnotationDidMove = NO;
    self.isMapFullSreen = NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
   
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self.mapView setDelegate:nil];
    [self setMapView:nil];
    [self setSearchButton:nil];
    [super viewDidUnload];
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.searchButton.hidden = YES;
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[R2RConstants getCellColor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (([self.route.segments count] * 2)+1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0)
    {
        int routeIndex = floor(indexPath.row/2);
        
        NSString *CellIdentifier = @"NameCell";
        
        R2RNameCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        [self configureNameCell:cell routeIndex:routeIndex];
        
        return cell;
    }
    else
    {
        int routeIndex = floor((indexPath.row%(([self.route.segments count] * 2)+1))/2);
        
        NSString *CellIdentifier = [self getCellIdentifier:[self.route.segments objectAtIndex:routeIndex]];
        
        id cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        cell = [self configureHopCell:cell segment:[self.route.segments objectAtIndex:routeIndex]];
        
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0)
    {
        return 37;//default height for route cell
    }
    else
    {
        return 54;
    }
}

-(NSString*) getCellIdentifier:(id) segment
{
    
    if([segment isKindOfClass:[R2RWalkDriveSegment class]])
    {
        return @"WalkDriveHopCell";
    }
    else if([segment isKindOfClass:[R2RTransitSegment class]])
    {
        return @"TransitHopCell";
    }
    else if([segment isKindOfClass:[R2RFlightSegment class]])
    {
        return @"FlightHopCell";
    }
    
    return nil;
}

-(void) configureNameCell:(R2RNameCell *)cell routeIndex: (NSInteger) routeIndex
{
    R2RStop *stop = [self.route.stops objectAtIndex:routeIndex];
    
    if ([stop.kind isEqualToString:@"airport"])
    {
        [cell.nameLabel setText: [NSString stringWithFormat:@"%@ (%@)", stop.name, stop.code]];
    }
    else
    {
        [cell.nameLabel setText:stop.name];
    }
    
    if (routeIndex == 0)
    {
        [cell.connectTop setHidden:YES];
    }
    else
    {
        [cell.connectTop setHidden:NO];
        R2RSprite *sprite = [R2RSegmentHelper getConnectionSprite:[self.route.segments objectAtIndex:routeIndex-1]];
        [self.searchStore.spriteStore setSpriteInView:sprite view:cell.connectTop];
    }
    
    if (routeIndex == [self.route.segments count])
    {
        [cell.connectBottom setHidden:YES];
    }
    else
    {
        [cell.connectBottom setHidden:NO];
        R2RSprite *sprite = [R2RSegmentHelper getConnectionSprite:[self.route.segments objectAtIndex:routeIndex]];
        [self.searchStore.spriteStore setSpriteInView:sprite view:cell.connectBottom];
    }
    
    CGRect connectionIconRect = [R2RConstants getConnectionIconRect];
    
    R2RSprite *sprite = [[R2RSprite alloc] initWithPath:[R2RConstants getIconSpriteFileName] :connectionIconRect.origin:connectionIconRect.size];
    
    [self.searchStore.spriteStore setSpriteInView:sprite view:cell.icon];
    
    [cell.contentView setBackgroundColor:[R2RConstants getBackgroundColor]];
    
    return;
}

-(id) configureHopCell:(id) cell segment:(id) segment
{
    if([cell isKindOfClass:[R2RWalkDriveHopCell class]])
    {
        return [self configureWalkDriveHopCell:cell segment:segment];
    }
    else if([cell isKindOfClass:[R2RTransitHopCell class]])
    {
        return [self configureTransitHopCell:cell segment:segment];
    }
    else if([cell isKindOfClass:[R2RFlightHopCell class]])
    {
        return [self configureFlightHopCell:cell segment:segment];
    }
    return nil;
}

-(R2RFlightHopCell *) configureFlightHopCell:(R2RFlightHopCell *) cell segment:(R2RFlightSegment *) segment
{
    NSInteger changes = [R2RSegmentHelper getFlightChangeCount:segment];
    
    NSString *hopDescription = [R2RStringFormatter formatFlightHopCellDuration:segment.duration];
    [cell.hopLabel setText:hopDescription];
    [cell.hopStops setText:[R2RStringFormatter formatFlightHopCellStops:changes]];
    
    R2RSprite *sprite = [R2RSegmentHelper getConnectionSprite:segment];
    [self.searchStore.spriteStore setSpriteInView:sprite view:cell.connectTop];
    [self.searchStore.spriteStore setSpriteInView:sprite view:cell.connectBottom];
    
    sprite = [R2RSegmentHelper getRouteSprite:[R2RSegmentHelper getSegmentSubkind:segment]];
    [self.searchStore.spriteStore setSpriteInView:sprite view:cell.icon];
    
    if (segment.indicativePrice.currency != NULL)
    {
        NSString *priceString = [R2RStringFormatter formatIndicativePrice:segment.indicativePrice];
        [cell.hopPrice setText:priceString];
        [cell.hopPrice setHidden:false];
    }
    else
    {
        [cell.hopPrice setHidden:true];
    }
    
    return cell;
}

-(R2RTransitHopCell *) configureTransitHopCell:(R2RTransitHopCell *) cell segment:(R2RTransitSegment *) segment
{
    NSInteger changes = [R2RSegmentHelper getTransitChangeCount:segment];
    NSString *vehicle = segment.vehicle;
    NSInteger frequency = [R2RSegmentHelper getTransitFrequency:segment];
    NSString *line = [R2RSegmentHelper getTransitLine:segment]; //line number for display if only 1 line and no changes
    
    NSString *hopDescription = [R2RStringFormatter formatTransitHopCellDuration:segment.duration changes:changes vehicle:vehicle line:line];
    [cell.hopLabel setText:hopDescription];
    [cell.hopFrequency setText:[R2RStringFormatter formatTransitHopCellFrequency:frequency]];
    
    R2RSprite *sprite = [R2RSegmentHelper getConnectionSprite:segment];
    [self.searchStore.spriteStore setSpriteInView:sprite view:cell.connectTop];
    [self.searchStore.spriteStore setSpriteInView:sprite view:cell.connectBottom];
    
    sprite = [R2RSegmentHelper getRouteSprite:[R2RSegmentHelper getSegmentSubkind:segment]];
    [self.searchStore.spriteStore setSpriteInView:sprite view:cell.icon];
    
    if (segment.indicativePrice.currency != NULL)
    {
        NSString *priceString = [R2RStringFormatter formatIndicativePrice:segment.indicativePrice];
        [cell.hopPrice setText:priceString];
        [cell.hopPrice setHidden:false];
    }
    else
    {
        [cell.hopPrice setHidden:true];
    }
    
    return cell;
}

-(R2RWalkDriveHopCell *) configureWalkDriveHopCell:(R2RWalkDriveHopCell *) cell segment:(R2RWalkDriveSegment *) segment
{
    NSString *vehicle = [segment.kind isEqualToString:@"walk"] ? @"foot" : segment.vehicle;
    NSString *hopDescription = [R2RStringFormatter formatWalkDriveHopCellDuration:segment.duration vehicle:vehicle];
    
    [cell.hopLabel setText:hopDescription];
    [cell.hopDistance setText:[R2RStringFormatter formatWalkDriveHopCellDistance:segment.distance isImperial:segment.isImperial]];
    
    R2RSprite *sprite = [R2RSegmentHelper getConnectionSprite:segment];
    [self.searchStore.spriteStore setSpriteInView:sprite view:cell.connectTop];
    [self.searchStore.spriteStore setSpriteInView:sprite view:cell.connectBottom];
    
    sprite = [R2RSegmentHelper getRouteSprite:[R2RSegmentHelper getSegmentSubkind:segment]];
    [self.searchStore.spriteStore setSpriteInView:sprite view:cell.icon];
    
    if (segment.indicativePrice.currency != NULL)
    {
        NSString *priceString = [R2RStringFormatter formatIndicativePrice:segment.indicativePrice];
        [cell.hopPrice setText:priceString];
        [cell.hopPrice setHidden:false];
    }
    else
    {
        [cell.hopPrice setHidden:true];
    }
    
    return cell;
}

-(NSString*) getSegmentKind:(id) segment
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showFlightSegment"])
    {
        R2RFlightSegmentViewController *segmentViewController = [segue destinationViewController];
        segmentViewController.searchManager = self.searchManager;
        segmentViewController.searchStore = self.searchStore;
        segmentViewController.route = self.route;
        segmentViewController.flightSegment = [self.route.segments objectAtIndex:([self.tableView indexPathForSelectedRow].row)/2];
        
        [segmentViewController sortFlightSegment];
    }
    if ([[segue identifier] isEqualToString:@"showTransitSegment"])
    {
        R2RTransitSegmentViewController *segmentViewController = [segue destinationViewController];
        segmentViewController.searchManager = self.searchManager;
        segmentViewController.searchStore = self.searchStore;
        segmentViewController.route = self.route;
        segmentViewController.transitSegment = [self.route.segments objectAtIndex:([self.tableView indexPathForSelectedRow].row)/2];
    }
    if ([[segue identifier] isEqualToString:@"showWalkDriveSegment"])
    {
        R2RWalkDriveSegmentViewController *segmentViewController = [segue destinationViewController];
        segmentViewController.searchManager = self.searchManager;
        segmentViewController.searchStore = self.searchStore;
        segmentViewController.route = self.route;
        segmentViewController.walkDriveSegment = [self.route.segments objectAtIndex:([self.tableView indexPathForSelectedRow].row)/2];
    }
}

- (void)showPressAnnotation:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    if (!self.pressAnnotation)
    {
        self.pressAnnotation = [[R2RAnnotation alloc] initWithName:@"Press" kind:nil coordinate:touchMapCoordinate annotationType:r2rAnnotationTypePress];
        [self.mapView addAnnotation:self.pressAnnotation];
    }
    else
    {
        [self.pressAnnotation setCoordinate:touchMapCoordinate];
    }
    [self.mapView selectAnnotation:self.pressAnnotation animated:YES];
}

-(void) setFromLocation:(id) sender
{
    for (id annotation in self.mapView.annotations)
    {
        if ([annotation isKindOfClass:[R2RAnnotation class]])
        {
            R2RAnnotation *r2rAnnotation = (R2RAnnotation *)annotation;
            
            if (r2rAnnotation.annotationType == r2rAnnotationTypeFrom)
            {
                [r2rAnnotation setCoordinate:self.pressAnnotation.coordinate];
                [self.mapView viewForAnnotation:r2rAnnotation].canShowCallout = NO;
                self.fromAnnotationDidMove = YES;
                [self.mapView deselectAnnotation:self.pressAnnotation animated:YES];
                [self showSearchButton];
                [self showFullScreenMap];
                break;
            }
        }
    }
}

-(void) setToLocation:(id) sender
{
    for (id annotation in self.mapView.annotations)
    {
        if ([annotation isKindOfClass:[R2RAnnotation class]])
        {
            R2RAnnotation *r2rAnnotation = (R2RAnnotation *)annotation;
            
            if (r2rAnnotation.annotationType == r2rAnnotationTypeTo)
            {
                [r2rAnnotation setCoordinate:self.pressAnnotation.coordinate];
                [self.mapView viewForAnnotation:r2rAnnotation].canShowCallout = NO;
                self.toAnnotationDidMove = YES;
                [self.mapView deselectAnnotation:self.pressAnnotation animated:YES];
                [self showSearchButton];
                [self showFullScreenMap];
                break;
            }
        }
    }
}

- (IBAction)returnToSearch:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)resolveLocation:(id)sender
{
    for (id annotation in self.mapView.annotations)
    {
        if ([annotation isKindOfClass:[R2RAnnotation class]])
        {
            R2RAnnotation *r2rAnnotation = (R2RAnnotation *)annotation;
            
            if (r2rAnnotation.annotationType == r2rAnnotationTypeFrom && self.fromAnnotationDidMove)
            {
                //mapcale. Used as horizontal accuracy
                float mapScale = self.zoomLevel*500;
                
                [self.searchManager setFromWithMapLocation:r2rAnnotation.coordinate mapScale:mapScale];
            }
            if (r2rAnnotation.annotationType == r2rAnnotationTypeTo && self.toAnnotationDidMove)
            {
                //mapcale. Used as horizontal accuracy
                float mapScale = self.zoomLevel*500;
                
                [self.searchManager setToWithMapLocation:r2rAnnotation.coordinate mapScale:mapScale];
            }
        }
    }
    
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)reloadDataDidFinish
{
    if (!IPAD)
    {
        //adjust table to correct size
        [self.tableView sizeToFit];

        // set map frame to non fullscreen size
        [self.tableView setHidden:NO];
        self.isMapFullSreen = NO;
        [self setMapFrame];
        
        //adjust table to correct size
        [self.tableView sizeToFit];
    }
    
    //draw table shadow
    self.tableView.layer.shadowOffset = CGSizeMake(0,5);
    self.tableView.layer.shadowRadius = 5;
    self.tableView.layer.shadowOpacity = 0.5;
    self.tableView.layer.masksToBounds = NO;
    self.tableView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.tableView.bounds].CGPath;
}

- (IBAction)resizeMap:(id)sender
{
    if (self.isMapFullSreen == NO)
    {
        [self showFullScreenMap];
    }
    else
    {
        [self showTableView];
    }
}

-(void) showFullScreenMap
{
    if (IPAD) return;
    
    if (self.isMapFullSreen == NO)
    {
        CGRect tableFrame = self.tableView.frame;
        tableFrame.origin.y = 0 - tableFrame.size.height;
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.tableView setFrame:tableFrame];
                             [self setMapFrameFullScreen];
                         }
                         completion:^(BOOL finished){
                         }];
        
        self.mapView.showsUserLocation = YES;
        self.isMapFullSreen = YES;
        [self.resizeMapButton setImage:[UIImage imageNamed:@"fullscreen1"] forState:UIControlStateNormal];
    }
}

-(void) showTableView
{
    if (self.isMapFullSreen == YES)
    {
        CGRect tableFrame = self.tableView.frame;
        tableFrame.origin.y = 0;
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.tableView setFrame:tableFrame];
                             [self setMapFrame];
                         }
                         completion:^(BOOL finished){
                         }];
        
        self.mapView.showsUserLocation = NO;
        self.isMapFullSreen = NO;
        [self.resizeMapButton setImage:[UIImage imageNamed:@"fullscreen2"] forState:UIControlStateNormal];
    }
}

-(void) setMapFrame
{
    // Don't adjust map position for ipad
    if (IPAD) return;
    
    CGRect viewFrame = self.view.frame;
    CGRect mapFrame = self.mapView.frame;
    
    if (self.tableView.frame.size.height < (viewFrame.size.height/3))
    {
        //set map to fill remaining screen space
        int height = (viewFrame.size.height - self.tableView.frame.size.height);
        mapFrame.size.height = height;
    }
    else
    {
        //set map to default height
        mapFrame.size.height = viewFrame.size.height*2/3;
    }
    
    //set map position to below footer
    mapFrame.origin.y = self.tableView.frame.size.height;
    
    //set map frame to new size and position
    [self.mapView setFrame:mapFrame];
    
    // adjust scrollview content size
    CGSize scrollviewSize = self.view.frame.size;
    scrollviewSize.height = self.tableView.frame.size.height + self.mapView.frame.size.height;
    UIScrollView *tempScrollView=(UIScrollView *)self.view;
    tempScrollView.contentSize=scrollviewSize;
    
    [self setMapButtonPositions];
}

-(void) setMapFrameFullScreen
{
    CGRect viewFrame = self.view.frame;
    if ([[UIDevice currentDevice].systemVersion floatValue] > 6.1) viewFrame.origin.y = 0;
    
    [self.mapView setFrame:viewFrame];
    
    // adjust scrollview content size
    CGSize scrollviewSize = self.view.frame.size;
    UIScrollView *tempScrollView=(UIScrollView *)self.view;
    tempScrollView.contentSize=scrollviewSize;
    
    [self setMapButtonPositions];
}

-(void) setMapButtonPositions
{
    CGRect buttonFrame = self.searchButton.frame;
    buttonFrame.origin.y = self.mapView.frame.origin.y + self.mapView.frame.size.height - 70;
    [self.searchButton setFrame:buttonFrame];
    
    buttonFrame = self.resizeMapButton.frame;
    buttonFrame.origin.y = self.mapView.frame.origin.y + 5;
    [self.resizeMapButton setFrame:buttonFrame];
}

-(void) setTableFooterWithGrabBar
{
    if (self.tableView.tableFooterView.frame.size.height != 0) return;
    
    float footerHeight = (IPAD) ? 10 : 6;
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [R2RConstants getTableWidth], footerHeight)];
    [footer setBackgroundColor:[R2RConstants getBackgroundColor]];
    
    float grabBarY = (IPAD) ? -1 : -6;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(([R2RConstants getTableWidth]/2) - 14, grabBarY, 27, 7)];
    [imageView setImage:[UIImage imageNamed:@"GrabTransparent1"]];
    imageView.userInteractionEnabled = YES;
    imageView.alpha = 0.2;
    
    [footer addSubview:imageView];
    
    self.tableView.tableFooterView = footer;
}

-(void) configureMap
{
    [self.mapView setDelegate:self];
    
    R2RMapHelper *mapHelper = [[R2RMapHelper alloc] initWithData:self.searchStore];
    
    NSArray *stopAnnotations = [mapHelper getRouteStopAnnotations:self.route];
    NSArray *hopAnnotations = [mapHelper getRouteHopAnnotations:self.route];
    
    hopAnnotations = [mapHelper filterHopAnnotations:hopAnnotations stopAnnotations:stopAnnotations regionSpan:self.mapView.region.span];
    
    for (R2RAnnotation *annotation in stopAnnotations)
    {
        [self.mapView addAnnotation:annotation];
    }
    
    for (R2RAnnotation *annotation in hopAnnotations)
    {
        [self.mapView addAnnotation:annotation];
    }
    
    [self setMapRegionDefault];
    
    for (id segment in self.route.segments)
    {
        NSArray *paths = [mapHelper getPolylines:segment];
        for (id path in paths)
        {
            [self.mapView addOverlay:path];
        }
    }
}

//set map to display main region for route
- (void)setMapRegionDefault
{
    R2RMapHelper *mapHelper = [[R2RMapHelper alloc] initWithData:self.searchStore];
    MKMapRect bounds = MKMapRectNull;
    
    for (id segment in self.route.segments)
    {
        MKMapRect segmentRect = [mapHelper getSegmentBounds:segment];
        bounds = MKMapRectUnion(bounds, segmentRect);
    }
    
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(bounds);
    
    if (region.span.longitudeDelta > 180) //if span is too large to fit on map just focus on destination
    {
        R2RStop *lastStop = [self.route.stops lastObject];
        region.center.latitude = lastStop.pos.lat;
        region.center.longitude = lastStop.pos.lng;
        region.span.longitudeDelta = 180.0f;
    }
    else
    {
        region.span.latitudeDelta *=1.1;
        region.span.longitudeDelta *=1.1;
    }
    
    self.zoomLevel = region.span.longitudeDelta;
    
    [self.mapView setRegion:region];
}

#pragma mark MKMapViewDelegate
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id) overlay
{
    R2RMapHelper *mapHelper = [[R2RMapHelper alloc] init];
	
    return [mapHelper getPolylineView:overlay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    R2RMapHelper *mapHelper = [[R2RMapHelper alloc] init];
	
    if ([annotation isKindOfClass:MKUserLocation.class])
    {
        return nil;
    }
    
    R2RAnnotation *r2rAnnotation = (R2RAnnotation *)annotation;
    
    MKAnnotationView *annotationView = [mapHelper getAnnotationView:mapView annotation:r2rAnnotation];
    
    if (r2rAnnotation.annotationType == r2rAnnotationTypePress)
    {
        R2RPressAnnotationView *pressAnnotationView = (R2RPressAnnotationView *)annotationView;
        [pressAnnotationView.fromButton addTarget:self
                                           action:@selector(setFromLocation:)
                                 forControlEvents:UIControlEventTouchUpInside];
        
        [pressAnnotationView.toButton addTarget:self
                                         action:@selector(setToLocation:)
                               forControlEvents:UIControlEventTouchUpInside];
        
        return pressAnnotationView;
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView calloutAccessoryControlTapped:(UIControl *)control
{
    if (self.isMapZoomedToAnnotation)
    {
        [self setMapRegionDefault];
        
        [self.mapView deselectAnnotation:annotationView.annotation animated:NO];
        
        self.isMapZoomedToAnnotation = NO;
    }
    else
    {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotationView.annotation.coordinate , 1000, 1000);
        
        self.zoomLevel = region.span.longitudeDelta;
        
        [self.mapView setRegion:region];
        
        [self.mapView deselectAnnotation:annotationView.annotation animated:NO];
        
        //must be after setRegion because isMapZoomedToAnnotation is set to NO when region changes
        self.isMapZoomedToAnnotation = YES;
    }
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    //hide press annotation when not selected
    if (view.annotation == self.pressAnnotation)
    {
        [self.mapView removeAnnotation:self.pressAnnotation];
        self.pressAnnotation = nil;
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (view.annotation != self.pressAnnotation)
    {
        R2RAnnotation *annotation = (R2RAnnotation *)view.annotation;
        if (annotation.annotationType == r2rAnnotationTypeFrom)
            self.fromAnnotationDidMove = YES;
        if (annotation.annotationType == r2rAnnotationTypeTo)
            self.toAnnotationDidMove = YES;
        
        [self showSearchButton];
        view.canShowCallout = NO;
        if (newState == MKAnnotationViewDragStateEnding)
        {
            [self.mapView deselectAnnotation:view.annotation animated:YES];
            [self showFullScreenMap];
        }
    }
}

-(void) showSearchButton
{
    CGRect buttonFrame = self.searchButton.frame;
    
    buttonFrame.origin.y = self.mapView.frame.origin.y + self.mapView.frame.size.height - 70;
    [self.searchButton setFrame:buttonFrame];
    self.searchButton.hidden = NO;
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    self.isMapZoomedToAnnotation = NO;
    if (self.zoomLevel!=mapView.region.span.longitudeDelta)
    {
        R2RMapHelper *mapHelper = [[R2RMapHelper alloc] initWithData:self.searchStore];
        
        NSArray *stopAnnotations = [mapHelper getRouteStopAnnotations:self.route];
        NSArray *hopAnnotations = [mapHelper getRouteHopAnnotations:self.route];
        
        hopAnnotations = [mapHelper filterHopAnnotations:hopAnnotations stopAnnotations:stopAnnotations regionSpan:self.mapView.region.span];
        
        //just get existing hopAnnotations
        NSMutableArray *existingHopAnnotations = [[NSMutableArray alloc] init];
        
        for (id annotation in mapView.annotations)
        {
            if ([annotation isKindOfClass:[R2RAnnotation class]])
            {
                R2RAnnotation *r2rAnnotation = (R2RAnnotation *)annotation;
                
                if (r2rAnnotation.annotationType == r2rAnnotationTypeHop)
                {
                    [existingHopAnnotations addObject:r2rAnnotation];
                }
            }
        }
        
        NSArray *annotationsToAdd = [mapHelper removeAnnotations:hopAnnotations :existingHopAnnotations];
        [self.mapView addAnnotations:annotationsToAdd];
        
        NSArray *annotationsToRemove = [mapHelper removeAnnotations:existingHopAnnotations :hopAnnotations];
        [self.mapView removeAnnotations:annotationsToRemove];
            
        self.zoomLevel=mapView.region.span.longitudeDelta;
    }
}

- (void) navigateBack
{
    if (self.isMapFullSreen == YES)
    {
        [self showTableView];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:true];
    }
}

@end
