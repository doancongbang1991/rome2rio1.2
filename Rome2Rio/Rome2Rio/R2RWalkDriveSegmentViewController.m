//
//  R2RWalkDriveSegmentViewController.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 30/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "R2RWalkDriveSegmentViewController.h"
#import "R2RStringFormatter.h"
#import "R2RConstants.h"

#import "R2RWalkDriveSegmentCell.h"
#import "R2RSegmentHelper.h"
#import "R2RMapHelper.h"
#import "R2RAnnotation.h"
#import "R2RPressAnnotationView.h"
#import "R2RTransitSegmentHeader.h"


@interface R2RWalkDriveSegmentViewController ()

@property (strong, nonatomic) R2RAnnotation *pressAnnotation;
@property CLLocationDegrees zoomLevel;
@property (nonatomic) BOOL isMapZoomedToAnnotation;

@property (nonatomic) bool fromAnnotationDidMove;
@property (nonatomic) bool toAnnotationDidMove;

@property (nonatomic) bool isMapFullSreen;

@end


@implementation R2RWalkDriveSegmentViewController

@synthesize searchManager, searchStore, route, walkDriveSegment;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *navigationTitle = [R2RStringFormatter capitaliseFirstLetter:[R2RSegmentHelper getSegmentSubkind:walkDriveSegment]];
    self.navigationItem.title = NSLocalizedString(navigationTitle, nil);
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(navigateBack)];
    self.navigationItem.leftBarButtonItem = backButton;
    
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

-(void)viewDidDisappear:(BOOL)animated
{
    self.searchButton.hidden = YES;
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self.mapView setDelegate:nil];
    [self setMapView:nil];
    [self setSearchButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (![self.walkDriveSegment.subkind isEqualToString:@"taxi"])
    {
        return [[UIView alloc]initWithFrame:CGRectZero];
    }
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, 35);
    
    R2RTransitSegmentHeader *header = [[R2RTransitSegmentHeader alloc] initWithFrame:rect];
    
    CGSize iconSize = CGSizeMake(24, 24);
    NSInteger startX = 19;
    rect = CGRectMake(startX, 6, iconSize.width, iconSize.height);
    [header.agencyIconView setFrame:rect];
    
    R2RSprite *sprite = [R2RSegmentHelper getRouteSprite:[R2RSegmentHelper getSegmentSubkind:self.walkDriveSegment]];
    
    [self.searchStore.spriteStore setSpriteInView:sprite view:header.agencyIconView];
    
    [header.agencyNameLabel setHidden:true];
    
    if (self.walkDriveSegment.indicativePrice.currency != NULL)
    {
        NSString *priceString = [R2RStringFormatter formatIndicativePrice:self.walkDriveSegment.indicativePrice];
        [header.segmentPrice setText:priceString];
        [header.segmentPrice setHidden:false];
    }
    else
    {
        [header.segmentPrice setHidden:true];
    }
    
    return header;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.walkDriveSegment.subkind isEqualToString:@"taxi"])
    {
        return 35;
    }
    
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WalkDriveSegmentCell";
    R2RWalkDriveSegmentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    R2RSprite *sprite = [R2RSegmentHelper getRouteSprite:[R2RSegmentHelper getSegmentSubkind: self.walkDriveSegment]];
    [self.searchStore.spriteStore setSpriteInView:sprite view:cell.kindIcon];
    
    NSString *sName = self.walkDriveSegment.sName;
    NSString *tName = self.walkDriveSegment.tName;
    
    for (R2RStop *stop in self.route.stops)
    {
        if ([self.walkDriveSegment.sName isEqualToString:stop.name])
        {
            if ( [stop.kind isEqualToString:@"airport"])
            {
                sName = [NSString stringWithFormat:@"%@ (%@)", stop.name, stop.code];
            }
        }
        if ([self.walkDriveSegment.tName isEqualToString:stop.name])
        {
            if ( [stop.kind isEqualToString:@"airport"])
            {
                tName = [NSString stringWithFormat:@"%@ (%@)", stop.name, stop.code];
            }
        }
    }
    
    [cell.fromLabel setText:sName];
    [cell.toLabel setText:tName];
    
    [cell.distanceLabel setText:[R2RStringFormatter formatDistance:self.walkDriveSegment.distance isImperial:self.walkDriveSegment.isImperial]];
    [cell.durationLabel setText:[R2RStringFormatter formatDuration:self.walkDriveSegment.duration]];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;//default height for walkDrive segment cell
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
    if (IPAD) return;
    
    //get the frame of the table section
    CGRect sectionFrame = [self.tableView rectForSection:0];
    
    CGRect viewFrame = self.view.frame;
    CGRect mapFrame = self.mapView.frame;
    
    if (sectionFrame.size.height < (viewFrame.size.height/3))
    {
        //set map to fill remaining screen space
        int height = (viewFrame.size.height - sectionFrame.size.height);
        mapFrame.size.height = height;
        
        //set the table footer to 0
        UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
        self.tableView.tableFooterView = footer;
        
        //set map position to below section
        mapFrame.origin.y = sectionFrame.size.height;
    }
    else
    {
        //set map to default height
        mapFrame.size.height = viewFrame.size.height*2/3;
        
        //set table footer
        [self setTableFooterWithGrabBar];
        
        //set map position to below footer
        mapFrame.origin.y = sectionFrame.size.height + self.tableView.tableFooterView.frame.size.height;
    }
    
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
    
    for (id segment in self.route.segments)
    {
        NSArray *paths = [mapHelper getPolylines:segment];
        for (id path in paths)
        {
            [self.mapView addOverlay:path];
        }
    }
    
    [self setMapRegionDefault];
}

- (void)setMapRegionDefault
{
    R2RMapHelper *mapHelper = [[R2RMapHelper alloc] init];
    MKMapRect bounds = [mapHelper getSegmentBounds:self.walkDriveSegment];
    
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(bounds);
    region.span.latitudeDelta *= 1.1;
    region.span.longitudeDelta *= 1.1;
    
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