//
//  R2RTransitSegmentViewController.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 29/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "R2RTransitSegmentViewController.h"
#import "R2RTransitSchedulesViewController.h"
#import "R2RStringFormatter.h"
#import "R2RConstants.h"

#import "R2RTransitSegmentHeader.h"
#import "R2RTransitSegmentCell.h"
#import "R2RSegmentHelper.h"
#import "R2RMapHelper.h"
#import "R2RAnnotation.h"
#import "R2RPressAnnotationView.h"

@interface R2RTransitSegmentViewController ()

@property (strong, nonatomic) R2RAnnotation *pressAnnotation;
@property (strong, nonatomic) NSMutableArray *legs;
@property CLLocationDegrees zoomLevel;
@property (nonatomic) BOOL isMapZoomedToAnnotation;
@property (strong, nonatomic) NSURL *schedulesURL;

@property (nonatomic) bool fromAnnotationDidMove;
@property (nonatomic) bool toAnnotationDidMove;

@property (nonatomic) bool isMapFullSreen;


@end

@implementation R2RTransitSegmentViewController

@synthesize searchManager, searchStore, route, transitSegment;

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    NSString *navigationTitle = [R2RStringFormatter capitaliseFirstLetter:[R2RSegmentHelper getSegmentSubkind:transitSegment]];
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
    
    self.legs = [NSMutableArray array];
    [self sortLegs];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showPressAnnotation:)];
    [self.mapView addGestureRecognizer:longPressGesture];
    
    [self configureMap];
    
    //after annotations are initially placed set DidMove to NO so we don't resolve again unless it changes
    self.fromAnnotationDidMove = NO;
    self.toAnnotationDidMove = NO;
    self.isMapFullSreen = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Table view data source

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, 35);
    
    R2RTransitSegmentHeader *header = [[R2RTransitSegmentHeader alloc] initWithFrame:rect];
    
    if ([self.transitSegment.itineraries count] == 0)
    {
        return header;
    }
    
    R2RTransitLeg *transitLeg = [self.legs objectAtIndex:section];
    R2RTransitHop *transitHop = [transitLeg.hops objectAtIndex:0];
    
    R2RTransitLine *transitLine = nil;
    if ([transitHop.lines count] > 0)
    {
        transitLine = [transitHop.lines objectAtIndex:0];
    }
    else
    {
        transitLine = [[R2RTransitLine alloc] init];
    }
    
    R2RAgency *agency  = [self.searchStore getAgency:transitLine.agency];
    
    NSString *agencyName = agency.name;
    if ([agencyName length] == 0)
    {
        agencyName = [R2RStringFormatter capitaliseFirstLetter:transitLine.vehicle];
    }
        
    if ([agency.iconPath length] == 0)
    {
        CGSize iconSize = CGSizeMake(24, 24);
        NSInteger startX = 19;
        rect = CGRectMake(startX, 5, iconSize.width, iconSize.height);
        [header.agencyIconView setFrame:rect];
        
        R2RSprite *sprite = [R2RSegmentHelper getRouteSprite:[R2RSegmentHelper getSegmentSubkind:transitSegment]];
        
        [self.searchStore.spriteStore setSpriteInView:sprite view:header.agencyIconView];
    }
    else
    {
        CGSize iconSize = CGSizeMake(27, 23);
        NSInteger startX = 15;
        rect = CGRectMake(startX, 6, iconSize.width, iconSize.height);
        [header.agencyIconView setFrame:rect];
        
        R2RSprite *sprite = [[R2RSprite alloc] initWithPath:agency.iconPath :agency.iconOffset :agency.iconSize];
        [self.searchStore.spriteStore setSpriteInView:sprite view:header.agencyIconView];
    }
    
    [header.agencyNameLabel setText:agencyName];
    
    if (transitSegment.indicativePrice.currency != NULL)
    {
        NSString *priceString = [R2RStringFormatter formatIndicativePrice:transitSegment.indicativePrice];
        [header.segmentPrice setText:priceString];
        [header.segmentPrice setHidden:false];
    }
    else
    {
        [header.segmentPrice setHidden:true];
    }
    
    return header;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return ([self.legs count]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.transitSegment.itineraries count] == 0) return 0;
    
    R2RTransitLeg *transitLeg = [self.legs objectAtIndex:section];
    
    return [transitLeg.hops count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TransitSegmentCell";
    R2RTransitSegmentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    R2RTransitLeg *transitLeg = [self.legs objectAtIndex:indexPath.section];
    R2RTransitHop *transitHop = [transitLeg.hops objectAtIndex:indexPath.row];
    
    NSString *sName = transitHop.sName;
    NSString *tName = transitHop.tName;
    
    for (R2RStop *stop in self.route.stops)
    {
        if ([transitHop.sName isEqualToString:stop.name])
        {
            if ( [stop.kind isEqualToString:@"airport"])
            {
                sName = [NSString stringWithFormat:@"%@ (%@)", stop.name, stop.code];
            }
        }
        if ([transitHop.tName isEqualToString:stop.name])
        {
            if ( [stop.kind isEqualToString:@"airport"])
            {
                tName = [NSString stringWithFormat:@"%@ (%@)", stop.name, stop.code];
            }
        }
    }
    
    [cell.fromLabel setText:sName];
    [cell.toLabel setText:tName];
    
    NSString *duration = [R2RStringFormatter formatDuration:transitHop.duration];
    NSString *frequency = [R2RStringFormatter formatFrequency:transitHop.frequency];
    NSString *description = [NSString stringWithFormat:@"%@, %@", duration, frequency];
    CGSize durationSize = [description sizeWithFont:[UIFont systemFontOfSize:17.0]];
    
    NSInteger startX = 40;
    
    CGRect rect = CGRectMake(startX, 30, durationSize.width, 25);
    [cell.durationLabel setFrame:rect];
    [cell.durationLabel setText:description];
    
    NSMutableString *lineLabel = [[NSMutableString alloc] init];
    
    for (R2RTransitLine *line in transitHop.lines)
    {
        if ([line.name length] > 0)
        {
            [lineLabel appendString:line.name];
            if (line != [transitHop.lines lastObject])
            {
                [lineLabel appendString:@", "];
            }
        }
    }
    
    if ([lineLabel length] > 0)
    {
        [cell.lineLabel setHidden:NO];
        NSString *line = [NSString stringWithFormat:@"Line: %@", lineLabel];
        [cell.lineLabel setText:line];
        rect = CGRectMake(20, 80, cell.toLabel.frame.size.width, 25);
        [cell.toLabel setFrame:rect];
        
        //set schedules button position
        rect = cell.schedulesButton.frame;
        rect.origin.y = 105;
        [cell.schedulesButton setFrame:rect];
    }
    else
    {
        [cell.lineLabel setHidden:YES];
        rect = CGRectMake(20, 55, cell.toLabel.frame.size.width, 25);
        [cell.toLabel setFrame:rect];
        
        //set schedules button position
        rect = cell.schedulesButton.frame;
        rect.origin.y = 80;
        [cell.schedulesButton setFrame:rect];
    }
    
    //if last row in section
    if (indexPath.row == [transitLeg.hops count] - 1)
    {
        [cell.schedulesButton setHidden:NO];
        
        //using tag to track which button is pressed
        cell.schedulesButton.tag = indexPath.section;
        [cell.schedulesButton addTarget:self action:@selector(showSchedules:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [cell.schedulesButton setHidden:YES];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    R2RTransitLeg *transitLeg = [self.legs objectAtIndex:indexPath.section];
    R2RTransitHop *transitHop = [transitLeg.hops objectAtIndex:indexPath.row];
    
    NSMutableString *lineLabel = [[NSMutableString alloc] init];
    
    for (R2RTransitLine *line in transitHop.lines)
    {
        [lineLabel appendString:line.name];
    }
    
    float rowHeight = 0;
    
    if ([lineLabel length] == 0)
    {
        rowHeight = 95;
    }
    else
    {
        rowHeight = 120;
    }
    
    //if last row in section
    if (indexPath.row == [transitLeg.hops count] - 1)
    {
        rowHeight += 20;
    }
    
    return rowHeight;
}

#pragma mark - Table view delegate

-(void) sortLegs
{
    R2RTransitItinerary *transitItinerary = [self.transitSegment.itineraries objectAtIndex:0];
    
    NSInteger count = 0;
    
    R2RTransitLine *prevHopLine = nil;
    
    for (R2RTransitLeg *transitLeg in transitItinerary.legs)
    {
        for (R2RTransitHop *transitHop in transitLeg.hops)
        {
            if ([transitHop.lines count] == 0) continue;
            
            R2RTransitLine *hopLine = [transitHop.lines objectAtIndex:0];
            
            if (![hopLine.agency isEqualToString:prevHopLine.agency])
            {
                R2RTransitLeg *newLeg = [[R2RTransitLeg alloc] init];
                newLeg.host = transitLeg.host;
                newLeg.url = transitLeg.url;
                
                newLeg.hops = [NSMutableArray array];
                [newLeg.hops addObject:transitHop];
                
                [self.legs addObject:newLeg];
                
                prevHopLine = hopLine;
                
                count++;
            }
            else
            {
                R2RTransitLeg *currentLeg = [self.legs objectAtIndex:count-1];
                [currentLeg.hops addObject:transitHop];
            }
        }
    }
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
    
    //calculate table height;
    float tableHeight = 0;
    for (NSInteger i = 0; i < self.tableView.numberOfSections; i++)
    {
        CGRect sectionFrame = [self.tableView rectForSection:i];
        tableHeight += sectionFrame.size.height;
    }
    
    CGRect viewFrame = self.view.frame;
    CGRect mapFrame = self.mapView.frame;
    
    if (tableHeight < (viewFrame.size.height/3))
    {
        //set map to fill remaining screen space
        int height = (viewFrame.size.height - tableHeight);
        mapFrame.size.height = height;
        
        //set the table footer to 0
        UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
        self.tableView.tableFooterView = footer;
        
        //set map position to below section
        mapFrame.origin.y = tableHeight;
    }
    else
    {
        //set map to default height
        mapFrame.size.height = viewFrame.size.height*2/3;
        
        //set table footer
        [self setTableFooterWithGrabBar];
        
        //set map position to below footer
        mapFrame.origin.y = tableHeight + self.tableView.tableFooterView.frame.size.height;
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
    MKMapRect bounds = [mapHelper getSegmentBounds:self.transitSegment];
    
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

- (void) showSchedules:(id) sender
{
    UIButton *button = (UIButton *)sender;
    
    R2RLog(@"Button %ld", (long)button.tag);
    
    R2RTransitLeg *leg = [self.legs objectAtIndex:button.tag];
    if ([[leg.url absoluteString] length] > 0)
    {
        self.schedulesURL = leg.url;
        [self performSegueWithIdentifier:@"showSchedules" sender:self];
        //[[UIApplication sharedApplication] openURL:leg.url];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showSchedules"])
    {
        R2RTransitSchedulesViewController *transitSchedulesViewController = [segue destinationViewController];
        transitSchedulesViewController.schedulesURL = self.schedulesURL;
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
