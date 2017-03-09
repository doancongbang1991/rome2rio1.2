//
//  R2RFlightSegmentViewController.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 14/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RFlightSegmentViewController.h"
#import "R2RFlightSegmentCell.h"
#import "R2RExpandedFlightSegmentCell.h"
#import "R2RFlightSegmentSectionHeader.h"
#import "R2RFlightGroup.h"

#import "R2RSpriteCache.h"
#import "R2RStringFormatter.h"
#import "R2RConstants.h"
#import "R2RSegmentHelper.h"
#import "R2RMapHelper.h"
#import "R2RAnnotation.h"
#import "R2RPressAnnotationView.h"


@interface R2RFlightSegmentViewController ()

@property (strong, nonatomic) R2RSpriteCache *spriteCache;
@property (strong, nonatomic) NSMutableArray *flightGroups;
@property (strong, nonatomic) NSIndexPath *selectedRowIndex; //current selected row. used for unselecting cell on second click

@property (strong, nonatomic) UIActionSheet *linkMenuSheet;
@property (strong, nonatomic) NSMutableArray *links;

@property (strong, nonatomic) R2RAnnotation *pressAnnotation;
@property CLLocationDegrees zoomLevel;
@property (nonatomic) BOOL isMapZoomedToAnnotation;

@property (nonatomic) bool fromAnnotationDidMove;
@property (nonatomic) bool toAnnotationDidMove;

@property (nonatomic) bool isMapFullSreen;

@end

@implementation R2RFlightSegmentViewController

@synthesize searchManager, searchStore, route, flightSegment;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Fly", nil);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(navigateBack)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [self.view setBackgroundColor:[R2RConstants getBackgroundColor]];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[R2RConstants getBackgroundColor]];
    
    [self.view sendSubviewToBack:self.mapView];
    
    // set default to show grabBar in footer
    [self setTableFooterWithGrabBar];
    
    [self.tableView setSectionHeaderHeight:55];
    
    //draw table shadow
    self.tableView.layer.shadowOffset = CGSizeMake(0,5);
    self.tableView.layer.shadowRadius = 5;
    self.tableView.layer.shadowOpacity = 0.5;
    self.tableView.layer.masksToBounds = NO;
    self.tableView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.tableView.bounds].CGPath;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showPressAnnotation:)];
    [self.mapView addGestureRecognizer:longPressGesture];
    
    [self configureMap];
    
    //after annotations are initially placed set DidMove to NO so we don't resolve again unless it changes
    self.fromAnnotationDidMove = NO;
    self.toAnnotationDidMove = NO;
    self.isMapFullSreen = NO;
    
    self.spriteCache = [[R2RSpriteCache alloc] init];    
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.searchButton.hidden = YES;
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    self.spriteCache = nil;
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
    return [self.flightGroups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    R2RFlightGroup *flightGroup = [self.flightGroups objectAtIndex:section];
    return [flightGroup.flights count];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, 50);
    
    R2RFlightSegmentSectionHeader *header = [[R2RFlightSegmentSectionHeader alloc] initWithFrame:rect];

    R2RFlightGroup *flightGroup = [self.flightGroups objectAtIndex:section];
    [header.titleLabel setText:flightGroup.name];
    
    NSString *from = [[NSString alloc] initWithString:self.flightSegment.sCode];
    NSString *to = [[NSString alloc] initWithString:self.flightSegment.tCode];

    NSString *routeString = [NSString stringWithFormat:NSLocalizedString(@"%@ to %@", nil), from, to];
    NSMutableAttributedString *coloredRouteString = [[NSMutableAttributedString alloc] initWithString:routeString];
    [coloredRouteString addAttribute:NSForegroundColorAttributeName value:[R2RConstants getButtonHighlightColor] range:NSMakeRange(0,from.length)];
    [coloredRouteString addAttribute:NSForegroundColorAttributeName value:[R2RConstants getButtonHighlightColor] range:NSMakeRange(routeString.length-to.length,to.length)];
    
    header.routeLabel.attributedText = coloredRouteString;
  
    R2RSprite *sprite = [R2RSegmentHelper getRouteSprite:[R2RSegmentHelper getSegmentSubkind:self.flightSegment]];
    
    [self.searchStore.spriteStore setSpriteInView:sprite view:header.iconView];
    
    
    if (self.flightSegment.indicativePrice.currency != NULL)
    {
        [header.priceText setText:NSLocalizedString(@"From", nil)];
        [header.priceText setHidden:false];
        
        NSString *priceString = [R2RStringFormatter formatIndicativePrice:self.flightSegment.indicativePrice];
        [header.segmentPrice setText:priceString];
        [header.segmentPrice setHidden:false];
    }
    else
    {
        [header.priceText setHidden:true];
        [header.segmentPrice setHidden:true];
    }
    
    return header;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedRowIndex && indexPath.section == self.selectedRowIndex.section && indexPath.row == self.selectedRowIndex.row)
    {
        [cell setBackgroundColor:[R2RConstants getExpandedCellColor]];
    }
    else	
    {
        [cell setBackgroundColor:[R2RConstants getCellColor]];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    
    R2RFlightGroup *flightGroup = [self.flightGroups objectAtIndex:indexPath.section];
    
    R2RFlightItinerary *flightItinerary = [flightGroup.flights objectAtIndex:indexPath.row];
    
    R2RFlightLeg *flightLeg = ([flightItinerary.legs count] > 0) ? [flightItinerary.legs objectAtIndex:0] : nil;
    
    if (indexPath.section == self.selectedRowIndex.section && indexPath.row == self.selectedRowIndex.row)
    {
        cellIdentifier = @"ExpandedFlightSegmentCell";
        R2RExpandedFlightSegmentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        [self configureExpandedFlightSegmentCell:cell flightLeg:flightLeg];
        
        return cell;
    }

    //else default cell
    cellIdentifier = @"FlightSegmentCell";
    R2RFlightSegmentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [self configureFlightSegmentCell:cell flightLeg:flightLeg];
    
    return cell;
}

-(void) configureFlightSegmentCell:(R2RFlightSegmentCell *) cell flightLeg:(R2RFlightLeg *) flightLeg
{
    NSInteger hops = [flightLeg.hops count];
    
    NSString *sTime = [[flightLeg.hops objectAtIndex:0] sTime];
    NSString *tTime = [[flightLeg.hops objectAtIndex:(hops-1)] tTime];
    
    [cell.sTimeLabel setText:sTime];
    [cell.tTimeLabel setText:tTime];
    
    float duration = 0.0;
    NSString *firstAirlineCode = nil;
    NSString *secondAirlineCode = nil;
    int hopNumber = 0;
    
    for (R2RFlightHop *flightHop in flightLeg.hops)
    {
        duration += flightHop.duration;
        if (flightHop.lDuration > 0)
        {
            duration += flightHop.lDuration;
        }
        
        if (firstAirlineCode == nil)
        {
            [cell setDisplaySingleIcon];
            firstAirlineCode = flightHop.airline;
        }
        else if (secondAirlineCode == nil && ![flightHop.airline isEqualToString:firstAirlineCode])
        {
            [cell setDisplayDoubleIcon];
            secondAirlineCode = flightHop.airline;
        }
        hopNumber++;
    }
    
    [cell.durationLabel setText:[R2RStringFormatter formatDurationZeroPadded:duration]];
    
    for (R2RAirline *airline in self.searchStore.searchResponse.airlines)
    {
        if ([airline.code isEqualToString:firstAirlineCode])
        {
            R2RSprite *sprite = [self.spriteCache getSprite :airline.iconPath :airline.iconOffset :airline.iconSize];
            [self.searchStore.spriteStore setSpriteInView:sprite view:cell.firstAirlineIcon];
        }
        if ([airline.code isEqualToString:secondAirlineCode])
        {
            R2RSprite *sprite = [self.spriteCache getSprite :airline.iconPath :airline.iconOffset :airline.iconSize];
            [self.searchStore.spriteStore setSpriteInView:sprite view:cell.secondAirlineIcon];
        }
    }
}

-(void) configureExpandedFlightSegmentCell:(R2RExpandedFlightSegmentCell *) cell flightLeg:(R2RFlightLeg *) flightLeg
{
    NSInteger hops = [flightLeg.hops count];
    
    NSString *sTime = [[flightLeg.hops objectAtIndex:0] sTime];
    NSString *tTime = [[flightLeg.hops objectAtIndex:(hops-1)] tTime];
    
    [cell.sTimeLabel setText:sTime];
    [cell.tTimeLabel setText:tTime];
    
    CGRect frame = cell.linkButton.frame;
    frame.origin.y = 75 + (50* (hops-1));
    [cell.linkButton setFrame:frame];
    
    R2RSprite *sprite = [R2RSegmentHelper getExternalLinkPinkSprite];
    [self.searchStore.spriteStore setSpriteInButton:sprite button:cell.linkButton];
    [cell.linkButton addTarget:self action:@selector(showLinkMenu) forControlEvents:UIControlEventTouchUpInside];
    
    frame = cell.frequencyLabel.frame;
    frame.origin.y = 75 + (50* (hops-1));
    [cell.frequencyLabel setFrame:frame];
    
    [cell.frequencyLabel setText:[R2RStringFormatter formatDays:flightLeg.days]];
    
    float duration = 0.0;
    NSString *firstAirlineCode = nil;
    NSString *secondAirlineCode = nil;
    int hopNumber = 0;
    
    for (R2RFlightHop *flightHop in flightLeg.hops)
    {
        duration += flightHop.duration;
        if (flightHop.lDuration > 0)
        {
            duration += flightHop.lDuration;
        }
        
        if (firstAirlineCode == nil)
        {
            [cell setDisplaySingleIcon];
            firstAirlineCode = flightHop.airline;
        }
        else if (secondAirlineCode == nil && ![flightHop.airline isEqualToString:firstAirlineCode])
        {
            [cell setDisplayDoubleIcon];
            secondAirlineCode = flightHop.airline;
        }
        
        [self setExpandedCellValues:cell :flightHop :hopNumber];
        
        hopNumber++;
    }
    
    [cell.durationLabel setText:[R2RStringFormatter formatDurationZeroPadded:duration]];
    
    for (R2RAirline *airline in self.searchStore.searchResponse.airlines)
    {
        if ([airline.code isEqualToString:firstAirlineCode])
        {
            R2RSprite *sprite = [self.spriteCache getSprite :airline.iconPath :airline.iconOffset :airline.iconSize];
            [self.searchStore.spriteStore setSpriteInView:sprite view:cell.firstAirlineIcon];
        }
        if ([airline.code isEqualToString:secondAirlineCode])
        {
            R2RSprite *sprite = [self.spriteCache getSprite :airline.iconPath :airline.iconOffset :airline.iconSize];
            [self.searchStore.spriteStore setSpriteInView:sprite view:cell.secondAirlineIcon];
        }
    }
    
    [self setUnusedViewsHidden:cell hops:hops];
}

-(void) setExpandedCellValues:(R2RExpandedFlightSegmentCell *)cell :(R2RFlightHop *)flightHop :(NSInteger) hopNumber
{
    UILabel *label;
    
    if (flightHop.lDuration > 0 && hopNumber > 0) //the layover should always be in the second hop but adding this for safety
    {
        R2RAirport *airport = [self.searchStore getAirport:flightHop.sCode];
        
        label = [cell.layoverNameLabels objectAtIndex:(hopNumber -1)];
        [label setText:[NSString stringWithFormat:NSLocalizedString(@"Layover at %@", nil), airport.name]];
        [label setHidden:NO];
        
        label = [cell.layoverDurationLabels objectAtIndex:(hopNumber - 1)];
        [label setText:[R2RStringFormatter formatDurationZeroPadded:flightHop.lDuration]];
        [label setHidden:NO];
    }
    
    R2RAirline *airline = [self.searchStore getAirline:flightHop.airline];
    UIImageView *imageView = [cell.airlineIcons objectAtIndex:hopNumber];
    R2RSprite *sprite = [self.spriteCache getSprite :airline.iconPath :airline.iconOffset :airline.iconSize];
    [self.searchStore.spriteStore setSpriteInView:sprite view:imageView];
    [imageView setHidden:NO];
    
    label = [cell.flightNameLabels objectAtIndex:hopNumber];
    [label setText:flightHop.flight];
    [label setHidden:NO];
    
    label = [cell.sAirportLabels objectAtIndex:hopNumber];
    [label setText:flightHop.sCode];
    [label setHidden:NO];
    
    label = [cell.tAirportLabels objectAtIndex:hopNumber];
    [label setText:flightHop.tCode];
    [label setHidden:NO];
    
    label = [cell.hopDurationLabels objectAtIndex:hopNumber];
    [label setText:[R2RStringFormatter formatDurationZeroPadded:flightHop.duration]];
    [label setHidden:NO];
}

-(void) setUnusedViewsHidden:(R2RExpandedFlightSegmentCell *) cell hops:(NSInteger) hops
{
    //1 less layover than stops
    for (long i = hops; i < MAX_FLIGHT_STOPS; i++)
    {
        UILabel *label = [cell.layoverNameLabels objectAtIndex:(i-1)];
        [label setHidden:YES];
        label = [cell.layoverDurationLabels objectAtIndex:(i-1)];
        [label setHidden:YES];
        
        UIImageView *view = [cell.airlineIcons objectAtIndex:i];
        [view setHidden:YES];
        label = [cell.flightNameLabels objectAtIndex:i];
        [label setHidden:YES];
        label = [cell.hopDurationLabels objectAtIndex:i];
        [label setHidden:YES];
        label = [cell.sAirportLabels objectAtIndex:i];
        [label setHidden:YES];
        label = [cell.tAirportLabels objectAtIndex:i];
        [label setHidden:YES];
        label = [cell.joinerLabels objectAtIndex:i];
        [label setHidden:YES];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSIndexPath *prevIndex = self.selectedRowIndex;

    if ([self isSelectedRowIndex:indexPath])
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.selectedRowIndex = nil;
    }
    else
    {
        self.selectedRowIndex = indexPath;
    }

    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:2];
    if (prevIndex)
        [indexPaths addObject:prevIndex];
    if (self.selectedRowIndex)
        [indexPaths addObject:self.selectedRowIndex];
    
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self isSelectedRowIndex:indexPath])
    {
        R2RFlightGroup *flightGroup = [self.flightGroups objectAtIndex:indexPath.section];
        R2RFlightItinerary *flightItinerary = [flightGroup.flights objectAtIndex:indexPath.row];
        R2RFlightLeg *flightLeg = [flightItinerary.legs objectAtIndex:0];
        NSInteger hops = [flightLeg.hops count];
        return (115+(50*(hops-1)));
    }
    
    return 30;
}

-(BOOL) isSelectedRowIndex:(NSIndexPath *)indexPath
{
    return self.selectedRowIndex &&
        indexPath.section == self.selectedRowIndex.section &&
        indexPath.row == self.selectedRowIndex.row;
}

-(void) sortFlightSegment
{
    self.flightGroups = [[NSMutableArray alloc] init];
    
    for (R2RFlightItinerary *itinerary in flightSegment.itineraries)
    {
        if ([itinerary.legs count] == 0)
        {
            continue;
        }
        
        R2RFlightLeg *leg = [itinerary.legs objectAtIndex:0];
        long hops = [leg.hops count];
        if (hops == 0)
        {
            continue;
        }
        
        R2RFlightGroup *flightGroup = nil;
        
        for (R2RFlightGroup *group in self.flightGroups)
        {
            if (group.hops == hops)
            {
                flightGroup = group;
                break;
            }
        }
        
        if (flightGroup == nil)
        {
            flightGroup = [[R2RFlightGroup alloc] initWithHops:hops];
            [self.flightGroups addObject:flightGroup];
        }
        
        [flightGroup.flights addObject:itinerary];
    }
    
    for (R2RFlightGroup *flightGroup in self.flightGroups)
    {
        [flightGroup.flights sortUsingComparator:^(R2RFlightItinerary *itin1, R2RFlightItinerary *itin2){
            R2RFlightLeg *leg1 = [itin1.legs objectAtIndex:0];
            R2RFlightLeg *leg2 = [itin2.legs objectAtIndex:0];
            R2RFlightHop *hop1 = [leg1.hops objectAtIndex:0];
            R2RFlightHop *hop2 = [leg2.hops objectAtIndex:0];
            return [hop1.sTime compare:hop2.sTime];
        }];
        
        [flightGroup.flights sortUsingComparator:^(R2RFlightItinerary *itin1, R2RFlightItinerary *itin2){
            R2RFlightLeg *leg1 = [itin1.legs objectAtIndex:0];
            R2RFlightLeg *leg2 = [itin2.legs objectAtIndex:0];
            R2RFlightHop *hop1 = [leg1.hops objectAtIndex:0];
            R2RFlightHop *hop2 = [leg2.hops objectAtIndex:0];
            return [hop1.airline compare:hop2.airline];
        }];
    }
}

- (void) showLinkMenu
{
    self.links = [[NSMutableArray alloc] init];
    
    NSIndexPath *indexPath = self.selectedRowIndex;
    
    R2RFlightGroup *flightGroup = [self.flightGroups objectAtIndex:indexPath.section];
    R2RFlightItinerary *flightItinerary = [flightGroup.flights objectAtIndex:indexPath.row];
    R2RFlightLeg *flightLeg = [flightItinerary.legs objectAtIndex:0];
    
    
    self.linkMenuSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"External Links", nil)
                                                     delegate:self
                                            cancelButtonTitle:nil
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:nil];

    NSMutableArray *airlines = [[NSMutableArray alloc] init];
    
    for (R2RFlightHop *flightHop in flightLeg.hops)
    {
        BOOL isDuplicateAirline = NO;
        for (R2RAirline *airline in airlines)
        {
            if ([flightHop.airline isEqualToString:airline.code])
            {
                isDuplicateAirline = YES;
                break;
            }
        }
        
        if (!isDuplicateAirline)
        {
            R2RAirline *airline = [self.searchStore getAirline:flightHop.airline];
            
            [airlines addObject:airline];
            
            [self.linkMenuSheet addButtonWithTitle:airline.name];
            [self.links addObject:airline.url];
        }
    }
    
    [self.linkMenuSheet addButtonWithTitle:NSLocalizedString(@"cancel", nil)];
    [self.linkMenuSheet setCancelButtonIndex:[airlines count]];
    
    [self.linkMenuSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [self.links count])
        return;
    
    R2RLog(@"Button %ld", (long)buttonIndex);
    NSURL *url = [self.links objectAtIndex:buttonIndex];
    if ([[url absoluteString] length] > 0)
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - Map Configuration

- (IBAction)resizeMap:(id)sender
{
}

-(void) showFullScreenMap
{
}

-(void) showTableView
{
}

-(void) setMapFrame
{
}

-(void) setMapFrameFullScreen
{
}

-(void) setMapButtonPositions
{
}

-(void) setTableFooterWithGrabBar
{
    if (self.tableView.tableFooterView.frame.size.height != 0) return;
    
    //same as resultsView
    float footerHeight = (IPAD) ? 15 : 10;
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [R2RConstants getTableWidth], footerHeight)];
    [footer setBackgroundColor:[R2RConstants getBackgroundColor]];
    
    float grabBarY = (IPAD) ? 4 : 1;
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
    R2RMapHelper *mapHelper = [[R2RMapHelper alloc] initWithData:self.searchStore];
    MKMapRect bounds = [mapHelper getSegmentBounds:self.flightSegment];
    
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
