//
//  R2RResultsViewController.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 6/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "R2RResultsViewController.h"
#import "R2RDetailViewController.h"
#import "R2RTransitSegmentViewController.h"
#import "R2RWalkDriveSegmentViewController.h"

#import "R2RStatusButton.h"
#import "R2RResultSectionHeader.h"
#import "R2RResultsCell.h"

#import "R2RStringFormatter.h"
#import "R2RSegmentHelper.h"
#import "R2RMapHelper.h"
#import "R2RConstants.h"
#import "R2RSprite.h"
#import "R2RAnnotation.h"
#import "R2RPressAnnotationView.h"

@interface R2RResultsViewController ()

@property (strong, nonatomic) R2RResultSectionHeader *header;
@property (strong, nonatomic) R2RStatusButton *statusButton;

@property (strong, nonatomic) R2RAnnotation *pressAnnotation;
@property (nonatomic) CLLocationDegrees zoomLevel;
@property (nonatomic) BOOL isMapZoomedToAnnotation;

@property (nonatomic) bool fromAnnotationDidMove;
@property (nonatomic) bool toAnnotationDidMove;

@property (strong, nonatomic) R2RAnnotation *fromAnnotation;
@property (strong, nonatomic) R2RAnnotation *toAnnotation;

@property (nonatomic) bool isMapFullSreen;

@end

@implementation R2RResultsViewController

@synthesize searchManager, searchStore;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = NSLocalizedString(@"Results", nil);
 
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(navigateBack)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTitle:) name:@"refreshTitle" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshResults:) name:@"refreshResults" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStatusMessage:) name:@"refreshStatusMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSearchMessage:) name:@"refreshSearchMessage" object:nil];
    
    [self.view setBackgroundColor:[R2RConstants getBackgroundColor]];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[R2RConstants getBackgroundColor]];
    
    [self.tableView setSectionHeaderHeight:37.0];
    
    CGRect rect = CGRectMake(0, 0, [R2RConstants getTableWidth], self.tableView.sectionHeaderHeight);
    
    self.header = [[R2RResultSectionHeader alloc] initWithFrame:rect];
    
    [self refreshResultsViewTitle];
    
    [self.view setBackgroundColor: [R2RConstants getBackgroundColor]];
    
    CGRect frame = CGRectMake(0.0, (self.view.bounds.size.height- self.navigationController.navigationBar.bounds.size.height-30), self.view.bounds.size.width, 30.0);
    if ([[UIDevice currentDevice].systemVersion floatValue] > 6.1) frame.origin.y -= 20; // temp fix to account for status bar in ios 7 until full redesign
    
    self.statusButton = [[R2RStatusButton alloc] initWithFrame:frame];
    [self.statusButton addTarget:self action:@selector(statusButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.statusButton];
    
    [self.view sendSubviewToBack:self.mapView];
    
    // set default to show grabBar in footer
    [self setTableFooterWithGrabBar];
    
    [self.mapView setDelegate:self];
    [self setMapRegionOnLoad];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showPressAnnotation:)];
    [self.mapView addGestureRecognizer:longPressGesture];
    
    //after annotations are initially placed set DidMove to NO so we don't resolve again unless it changes
    self.fromAnnotationDidMove = NO;
    self.toAnnotationDidMove = NO;
    self.isMapFullSreen = NO;
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshTitle" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshResults" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshStatusMessage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshSearchMessage" object:nil];
    
    [self setTableView:nil];
    [self.mapView setDelegate:nil];
    [self setMapView:nil];
    [self setSearchButton:nil];
    [self setResizeMapButton:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //if there is a status message show it otherwise show search message
    if ([self.searchStore.statusMessage length] > 0)
    {
        [self setStatusMessage:self.searchStore.statusMessage];
    }
    else
    {
        [self setStatusMessage:self.searchStore.searchMessage];
        if ([self.searchManager isSearching]) [self.searchManager setSearchMessage:NSLocalizedString(@"Searching", nil)];
    }
    
    // clear from annotation in no from place resolved yet
    if (self.searchStore.fromPlace == nil)
    {
        if (self.fromAnnotation != nil)
        {
            [self.mapView removeAnnotation:self.fromAnnotation];
            self.fromAnnotation = nil;
        }
    }
    
    // clear to annotation in no to place resolved yet
    if (self.searchStore.toPlace == nil)
    {
        if (self.toAnnotation != nil)
        {
            [self.mapView removeAnnotation:self.toAnnotation];
            self.toAnnotation = nil;
        }
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    if ([self.searchManager isSearching]) [self.searchManager setSearchMessage:@""];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.header;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchStore.searchResponse.routes count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[R2RConstants getCellColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    R2RRoute *route = [self.searchStore.searchResponse.routes objectAtIndex:indexPath.row];
    NSString *CellIdentifier = @"ResultsCell";
    
    if ([route.segments count] == 1)
    {
        NSString *kind = [R2RSegmentHelper getSegmentKind:[route.segments objectAtIndex:0]];
        if ([kind isEqualToString:@"bus"] || [kind isEqualToString:@"train"] || [kind isEqualToString:@"ferry"])
        {
            CellIdentifier = @"ResultsCellTransit";
        }
        else if ([kind isEqualToString:@"car"] || [kind isEqualToString:@"walk"])
        {
            CellIdentifier = @"ResultsCellWalkDrive";
        }
    }
    
    R2RResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell.resultDescripionLabel setText:route.name];
    [cell.resultDurationLabel setText:[R2RStringFormatter formatDuration:route.duration]];
    
    NSInteger iconCount = 0;
    NSString *prevSegmentKind = @"";
    NSMutableArray *spriteList = [[NSMutableArray alloc] initWithCapacity:MAX_ICONS];
    for (id segment in route.segments)
    {
        if (iconCount >= MAX_ICONS) break;
        
        if ([R2RSegmentHelper getSegmentIsMajor:segment])
        {
            NSString *segmentKind = [R2RSegmentHelper getSegmentSubkind:segment];
            
            if (iconCount > 0)
            {
                // do not display the same icon consecutively
                if ([segmentKind isEqualToString:prevSegmentKind])
                    continue;
            }
            
            R2RSprite *sprite = [R2RSegmentHelper getRouteSprite:segmentKind];
            
            [spriteList addObject:sprite];
            
            prevSegmentKind = segmentKind;
            iconCount++;
        }
    }
    
    if (route.indicativePrice.currency != NULL)
    {
        NSString *priceString = [R2RStringFormatter formatIndicativePrice:route.indicativePrice];
        [cell.resultPriceLabel setText:priceString];
        [cell.resultPriceLabel setHidden:false];
    }
    else
    {
        [cell.resultPriceLabel setHidden:true];
    }
    
    for (int i = 0; i < iconCount; i++)
    {
        R2RSprite *sprite = [spriteList objectAtIndex:i];
        
        NSInteger spritePos = iconCount - 1 - i;
        UIImageView *iconView = [cell.icons objectAtIndex:spritePos];
        
        [self.searchStore.spriteStore setSpriteInView:sprite view:iconView];
    }
    
    // dynamic description size depending on number if icons
    CGRect rect = cell.resultDescripionLabel.frame;
    rect.size.width = cell.bounds.size.width-(45+(25*iconCount));
    [cell.resultDescripionLabel setFrame:rect];
    
    cell.iconCount = iconCount;
    
    return cell;
}

#pragma mark - Table view delegate

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showRouteDetails"])
    {
        R2RDetailViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.searchManager = self.searchManager;
        detailsViewController.searchStore = self.searchStore;
        detailsViewController.route = [self.searchStore.searchResponse.routes objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    }
    if ([[segue identifier] isEqualToString:@"showTransitSegment"])
    {
        R2RTransitSegmentViewController *segmentViewController = [segue destinationViewController];
        R2RRoute *route = [self.searchStore.searchResponse.routes objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        segmentViewController.searchManager = self.searchManager;
        segmentViewController.searchStore = self.searchStore;
        segmentViewController.route = route;
        segmentViewController.transitSegment = [route.segments objectAtIndex:0];
    }
    if ([[segue identifier] isEqualToString:@"showWalkDriveSegment"])
    {
        R2RWalkDriveSegmentViewController *segmentViewController = [segue destinationViewController];
        R2RRoute *route = [self.searchStore.searchResponse.routes objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        segmentViewController.searchManager = self.searchManager;
        segmentViewController.searchStore = self.searchStore;
        segmentViewController.route = route;
        segmentViewController.walkDriveSegment = [route.segments objectAtIndex:0];
    }
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
}

-(void) statusButtonClicked
{
    [self.navigationController popViewControllerAnimated:true];
}

-(void) refreshResultsViewTitle
{
    
    NSString *from = (self.searchStore.fromPlace) ? self.searchStore.fromPlace.shortName: NSLocalizedString(@"finding", nil);
    NSString *to = (self.searchStore.toPlace) ? self.searchStore.toPlace.shortName: NSLocalizedString(@"finding", nil);

    NSMutableString *title = [NSMutableString stringWithFormat:NSLocalizedString(@"%@ to %@", nil), from, to];
    NSMutableAttributedString *coloredTitle = [[NSMutableAttributedString alloc] initWithString:title];
    [coloredTitle addAttribute:NSForegroundColorAttributeName value:[R2RConstants getButtonHighlightColor] range:NSMakeRange(0,from.length)];
    [coloredTitle addAttribute:NSForegroundColorAttributeName value:[R2RConstants getButtonHighlightColor] range:NSMakeRange(title.length-to.length,to.length)];

    self.header.titleLabel.attributedText = coloredTitle;
}

-(void) refreshTitle:(NSNotification *) notification
{
    [self refreshResultsViewTitle];
}

-(void) refreshResults:(NSNotification *) notification
{
    if (!IPAD)
    {
        //resize table view frame back to max
        CGRect frame = self.tableView.frame;
        frame.size.height = 10088;
        self.tableView.frame = frame;
    }
        
    //remove hop annotations and stop annotations that are not to/from
    for (id annotation in self.mapView.annotations)
    {
        if ([annotation isKindOfClass:[R2RAnnotation class]])
        {
            R2RAnnotation *r2rAnnotation = (R2RAnnotation *)annotation;
            
            if (r2rAnnotation.annotationType != r2rAnnotationTypeFrom && r2rAnnotation.annotationType != r2rAnnotationTypeTo)
            {
                [self.mapView removeAnnotation:r2rAnnotation];
            }
        }
    }
    
    // remove overlays
    [self.mapView removeOverlays:self.mapView.overlays];
    
    //reload table. triggers redrawing of map as well
    [self.tableView reloadData];
}

-(void) refreshStatusMessage:(NSNotification *) notification
{
    [self setStatusMessage:self.searchStore.statusMessage];
}

-(void) refreshSearchMessage:(NSNotification *) notification
{
    [self setStatusMessage:self.searchStore.searchMessage];
}

-(void) setStatusMessage: (NSString *) message
{
    [self.statusButton setTitle:message forState:UIControlStateNormal];
}

- (void)showPressAnnotation:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (self.searchManager.searchStore.searchResponse == nil && [self.searchManager isSearching]) return;
    
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
    [self updateFromAnnotation:@"From" kind:nil coord:self.pressAnnotation.coordinate];
    [self.mapView viewForAnnotation:self.fromAnnotation].canShowCallout = NO;
    self.fromAnnotationDidMove = YES;
    [self.mapView deselectAnnotation:self.pressAnnotation animated:YES];
    [self showSearchButton];
    [self showFullScreenMap];
}

-(void) setToLocation:(id) sender
{
    [self updateToAnnotation:@"To" kind:nil coord:self.pressAnnotation.coordinate];
    [self.mapView viewForAnnotation:self.toAnnotation].canShowCallout = NO;
    self.toAnnotationDidMove = YES;
    [self.mapView deselectAnnotation:self.pressAnnotation animated:YES];
    [self showSearchButton];
    [self showFullScreenMap];
}

-(void) updateFromAnnotation:(NSString *)name kind:(NSString *)kind coord:(CLLocationCoordinate2D) fromCoord
{
    // reuse from annotation if already exists or add it
    if (self.fromAnnotation == nil)
    {
        self.fromAnnotation = [[R2RAnnotation alloc] initWithName:name kind:kind coordinate:fromCoord annotationType:r2rAnnotationTypeFrom];
        [self.mapView addAnnotation:self.fromAnnotation];
    }
    else
    {
        [self.fromAnnotation setCoordinate:fromCoord];
        [self.fromAnnotation setName:name];
        [self.fromAnnotation setKind:kind];
    }
}

-(void) updateToAnnotation:(NSString *)name kind:(NSString *)kind coord:(CLLocationCoordinate2D) toCoord
{
    // reuse from annotation if already exists or add it
    if (self.toAnnotation == nil)
    {
        self.toAnnotation = [[R2RAnnotation alloc] initWithName:name kind:kind coordinate:toCoord annotationType:r2rAnnotationTypeTo];
        [self.mapView addAnnotation:self.toAnnotation];
    }
    else
    {
        [self.toAnnotation setCoordinate:toCoord];
        [self.toAnnotation setName:name];
        [self.toAnnotation setKind:kind];
    }
}

- (IBAction)returnToSearch:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)resolveLocation:(id)sender
{
    if (self.fromAnnotation && self.fromAnnotationDidMove)
    {
        //mapcale. Used as horizontal accuracy
        float mapScale = self.zoomLevel*500;
        
        [self.searchManager setFromWithMapLocation:self.fromAnnotation.coordinate mapScale:mapScale];
    }
    
    if (self.toAnnotation && self.toAnnotationDidMove)
    {
        //mapcale. Used as horizontal accuracy
        float mapScale = self.zoomLevel*500;
        
        [self.searchManager setToWithMapLocation:self.toAnnotation.coordinate mapScale:mapScale];
    }
    
    self.fromAnnotationDidMove = NO;
    self.toAnnotationDidMove = NO;
    
    self.searchButton.hidden = YES;
}

-(void)reloadDataDidFinish
{
    [self configureMap];
    
    if (!IPAD)
    {
        CGRect tableFrame = self.tableView.frame;
    //    tableFrame.size.height = 1000; //added to make sizeToFit work better //TODO CHECK THIS, done it refresh data notification
        tableFrame.origin.y = 0; // set table back to top of
        [self.tableView setFrame:tableFrame];
        
        //adjust table to correct size
        [self.tableView sizeToFit];
        
        // set map frame to non fullscreen size
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
    
    //unique footer configuration for resultsView
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
    R2RMapHelper *mapHelper = [[R2RMapHelper alloc] initWithData:self.searchStore];
    
    [self setMapRegion];
    
    //return if search is not complete or route not found
    if ([self.searchStore.searchResponse.routes count] == 0)
    {
        //display any available to/from annotations
        if (self.searchStore.fromPlace && !self.fromAnnotationDidMove)
        {
            CLLocationCoordinate2D fromCoord = CLLocationCoordinate2DMake(self.searchManager.searchStore.fromPlace.lat , self.searchManager.searchStore.fromPlace.lng);
            
            [self updateFromAnnotation:self.searchManager.searchStore.fromPlace.longName kind:self.searchManager.searchStore.fromPlace.kind coord:fromCoord];
            [self.mapView viewForAnnotation:self.fromAnnotation].canShowCallout = YES;
        }
    
        if (self.searchStore.toPlace && ! self.toAnnotationDidMove)
        {
            CLLocationCoordinate2D toCoord = CLLocationCoordinate2DMake(self.searchManager.searchStore.toPlace.lat , self.searchManager.searchStore.toPlace.lng);
            
            [self updateToAnnotation:self.searchManager.searchStore.toPlace.longName kind:self.searchManager.searchStore.toPlace.kind coord:toCoord];
            [self.mapView viewForAnnotation:self.toAnnotation].canShowCallout = YES;
        }
        
        return;
    }
    
    R2RRoute *route = [self.searchStore.searchResponse.routes objectAtIndex:0];
    
    NSArray *stopAnnotations = [mapHelper getRouteStopAnnotations:route];
    NSArray *hopAnnotations = [mapHelper getRouteHopAnnotations:route];
    
    hopAnnotations = [mapHelper filterHopAnnotations:hopAnnotations stopAnnotations:stopAnnotations regionSpan:self.mapView.region.span];
    
    for (R2RAnnotation *annotation in stopAnnotations)
    {
        if (annotation.annotationType == r2rAnnotationTypeFrom)
        {
            [self updateFromAnnotation:annotation.name kind:annotation.kind coord:annotation.coordinate];
            continue;
        }
        if (annotation.annotationType == r2rAnnotationTypeTo)
        {
            [self updateToAnnotation:annotation.name kind:annotation.kind coord:annotation.coordinate];
            continue;
        }
        [self.mapView addAnnotation:annotation];
    }
    
    for (R2RAnnotation *annotation in hopAnnotations)
    {
        [self.mapView addAnnotation:annotation];
    }
    
    for (id segment in route.segments)
    {
        NSArray *paths = [mapHelper getPolylines:segment];
        for (id path in paths)
        {
            [self.mapView addOverlay:path];
        }
    }
}

- (void) setMapRegionOnLoad
{
    // get default region
    MKCoordinateRegion region = [R2RConstants getStartMapRegion];
    
    // if a place exists with no search response set region to that area
    if (self.searchStore.fromPlace)
    {
        CLLocationCoordinate2D fromCoord = CLLocationCoordinate2DMake(self.searchManager.searchStore.fromPlace.lat , self.searchManager.searchStore.fromPlace.lng);
        region = MKCoordinateRegionMakeWithDistance(fromCoord , 50000, 50000);
    }
    else if (self.searchStore.toPlace)
    {
        CLLocationCoordinate2D toCoord = CLLocationCoordinate2DMake(self.searchManager.searchStore.toPlace.lat , self.searchManager.searchStore.toPlace.lng);
        region = MKCoordinateRegionMakeWithDistance(toCoord , 50000, 50000);
    }

    [self.mapView setRegion:region];
    self.zoomLevel = region.span.longitudeDelta;
    
    // set mapRegion animated if search routes available
    [self setMapRegion];
    
}

//set map to display main region for route
- (void)setMapRegion
{
    if ([self.searchStore.searchResponse.routes count] == 0)
    {
        return;
    }
    
    R2RRoute *route = [self.searchStore.searchResponse.routes objectAtIndex:0];
    
    R2RMapHelper *mapHelper = [[R2RMapHelper alloc] initWithData:self.searchStore];
    MKMapRect bounds = MKMapRectNull;
    
    for (id segment in route.segments)
    {
        MKMapRect segmentRect = [mapHelper getSegmentBounds:segment];
        bounds = MKMapRectUnion(bounds, segmentRect);
    }
    
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(bounds);
    
    if (region.span.longitudeDelta > 180) //if span is too large to fit on map just focus on destination
    {
        R2RStop *lastStop = [route.stops lastObject];
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
    
    //    [self.mapView setRegion:region];
    [self.mapView setRegion:region animated:YES];
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
        [self setMapRegion];
        
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
    if (view.annotation == self.fromAnnotation || view.annotation == self.toAnnotation)
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

    self.searchButton.hidden = NO;

}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    self.isMapZoomedToAnnotation = NO;
    if (self.zoomLevel!=mapView.region.span.longitudeDelta)
    {
        R2RMapHelper *mapHelper = [[R2RMapHelper alloc] initWithData:self.searchStore];
        
        //return if search is not complete or route not found
        if ([self.searchStore.searchResponse.routes count] == 0)
            return;
        
        R2RRoute *route = [self.searchStore.searchResponse.routes objectAtIndex:0];
        
        NSArray *stopAnnotations = [mapHelper getRouteStopAnnotations:route];
        NSArray *hopAnnotations = [mapHelper getRouteHopAnnotations:route];
        
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
