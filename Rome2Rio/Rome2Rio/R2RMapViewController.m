//
//  R2RMapViewController.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 21/11/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RMapViewController.h"
#import "R2RAnnotation.h"
#import "R2RStatusButton.h"
#import "R2RMapHelper.h"
#import "R2RConstants.h"

#import "R2RPressAnnotationView.h"

@interface R2RMapViewController ()

@property (strong, nonatomic) R2RStatusButton *statusButton;

@property (strong, nonatomic) R2RAnnotation *fromAnnotation;
@property (strong, nonatomic) R2RAnnotation *toAnnotation;
@property (strong, nonatomic) R2RAnnotation *pressAnnotation;

@property (nonatomic) bool fromAnnotationDidMove;
@property (nonatomic) bool toAnnotationDidMove;

@end

@implementation R2RMapViewController

@synthesize searchManager, fieldName;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.mapView setDelegate:self];
    
//    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(47.0 , -120.0);
//    
//    R2RAnnotation *annotation = [[R2RAnnotation alloc] initWithName:nil kind:nil coordinate:coord annotationType:r2rAnnotationTypeFrom];
//    [self.mapView addAnnotation:annotation];

    MKCoordinateRegion region = [R2RConstants getStartMapRegion];
    
    // if selecting from and a from location has previousy been selected start map zoomed in on that location instead of world
    if (self.searchManager.searchStore.fromPlace)
    {
        CLLocationCoordinate2D fromCoord = CLLocationCoordinate2DMake(self.searchManager.searchStore.fromPlace.lat , self.searchManager.searchStore.fromPlace.lng);
        
        if ([self.fieldName isEqualToString:@"from"] || ([self.fieldName isEqualToString:@"to"] && !self.searchManager.searchStore.toPlace))
        {
            region = MKCoordinateRegionMakeWithDistance(fromCoord , 50000, 50000);
        }
        [self setFromLocation:fromCoord];
        
    }
    
    if (self.searchManager.searchStore.toPlace)
    {
        CLLocationCoordinate2D toCoord = CLLocationCoordinate2DMake(self.searchManager.searchStore.toPlace.lat , self.searchManager.searchStore.toPlace.lng);
        
        
        if ([self.fieldName isEqualToString:@"to"])
        {
            region = MKCoordinateRegionMakeWithDistance(toCoord , 50000, 50000);
        }
        [self setToLocation:toCoord];
    }
    
    //after annotations are initially placed set DidMove to NO so we don't resolve again unless it changes
    self.fromAnnotationDidMove = NO;
    self.toAnnotationDidMove = NO;
        
    [self.mapView setRegion:region];

    self.navigationItem.title = NSLocalizedString(@"Select location", nil);
    
    CGRect frame = CGRectMake(0.0, (self.view.bounds.size.height- self.navigationController.navigationBar.bounds.size.height-30), self.view.bounds.size.width, 30.0);
    if ([[UIDevice currentDevice].systemVersion floatValue] > 6.1) frame.origin.y -= 20; // temp fix to account for status bar in ios 7 until full redesign
    
    self.statusButton = [[R2RStatusButton alloc] initWithFrame:frame];
    [self.view addSubview:self.statusButton];
        
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setAnnotationForTap:)];
    [self.mapView addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showPressAnnotation:)];
    [self.mapView addGestureRecognizer:longPressGesture];
    longPressGesture.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}

- (IBAction)resolveLocation:(id)sender
{
    //if no location is currently selected display instructions
    if ([self.fieldName isEqualToString:@"from"] && !self.fromAnnotation)
    {
        [self.statusButton setTitle:@"Select origin" forState:UIControlStateNormal];
        return;
    }
    else if ([self.fieldName isEqualToString:@"to"] && !self.toAnnotation)
    {
        [self.statusButton setTitle:@"Select destination" forState:UIControlStateNormal];
        return;
    }
    
    if (self.fromAnnotation && self.fromAnnotationDidMove)
    {
        //mapcale. Used as horizontal accuracy
        float mapScale = self.mapView.region.span.longitudeDelta*500;

        [self.searchManager setFromWithMapLocation:self.fromAnnotation.coordinate mapScale:mapScale];
    }
    
    if (self.toAnnotation && self.toAnnotationDidMove)
    {
        //mapcale. Used as horizontal accuracy
        float mapScale = self.mapView.region.span.longitudeDelta*500;
        
        [self.searchManager setToWithMapLocation:self.toAnnotation.coordinate mapScale:mapScale];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)returnToSearch:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showPressAnnotation:(UILongPressGestureRecognizer *)gestureRecognizer
{
    [self.statusButton setTitle:nil forState:UIControlStateNormal];
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];

    if (!self.pressAnnotation)
    {
        self.pressAnnotation = [[R2RAnnotation alloc] initWithName:@" " kind:nil coordinate:touchMapCoordinate annotationType:r2rAnnotationTypePress];
        [self.mapView addAnnotation:self.pressAnnotation];
    }
    else
    {
        [self.pressAnnotation setCoordinate:touchMapCoordinate];
    }
    
    [self.mapView selectAnnotation:self.pressAnnotation animated:YES];
}

#pragma mark MKMapViewDelegate
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
        if (view.annotation == self.fromAnnotation)
            self.fromAnnotationDidMove = YES;
        
        if (view.annotation == self.toAnnotation)
            self.toAnnotationDidMove = YES;
            
        if (newState == MKAnnotationViewDragStateEnding)
        {
            [self.mapView deselectAnnotation:view.annotation animated:YES];
        }
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
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
                                         action:@selector(setFromLocationFromLongPress:)
                               forControlEvents:UIControlEventTouchUpInside];
        
        [pressAnnotationView.toButton addTarget:self
                                       action:@selector(setToLocationFromLongPress:)
                             forControlEvents:UIControlEventTouchUpInside];
        
        return pressAnnotationView;
    }
    
    //this makes the annotations draggable without a title
    annotationView.canShowCallout = NO;
    
    return annotationView;
}

- (void)setAnnotationForTap :(UITapGestureRecognizer *)gestureRecognizer
{
    if (self.pressAnnotation)
    {
        [self.mapView deselectAnnotation:self.pressAnnotation animated:YES];
    }
    
    [self.statusButton setTitle:nil forState:UIControlStateNormal];
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    if ([self.fieldName isEqualToString:@"from"])
    {
        [self setFromLocation:touchMapCoordinate];
    }
    if ([self.fieldName isEqualToString:@"to"])
    {
        [self setToLocation:touchMapCoordinate];
    }
}

-(void) setFromLocationFromLongPress:(id) sender
{
    [self setFromLocation:self.pressAnnotation.coordinate];
    
    [self.mapView deselectAnnotation:self.pressAnnotation animated:YES];
}

-(void) setToLocationFromLongPress:(id) sender
{
    [self setToLocation:self.pressAnnotation.coordinate];
    
    [self.mapView deselectAnnotation:self.pressAnnotation animated:YES];
}

-(void) setFromLocation:(CLLocationCoordinate2D) coord
{
    if (!self.fromAnnotation)
    {
        //TODO maybe add a name here so magnifying glass is shown and then set it to zoom to different levels
        self.fromAnnotation = [[R2RAnnotation alloc] initWithName:nil kind:nil coordinate:coord annotationType:r2rAnnotationTypeFrom];
        [self.mapView addAnnotation:self.fromAnnotation];
    }
    else
    {
        [self.fromAnnotation setCoordinate:coord];
    }
    self.fromAnnotationDidMove = YES;
}

-(void) setToLocation:(CLLocationCoordinate2D) coord
{
    if (!self.toAnnotation)
    {
        self.toAnnotation = [[R2RAnnotation alloc] initWithName:nil kind:nil coordinate:coord annotationType:r2rAnnotationTypeTo];
        [self.mapView addAnnotation:self.toAnnotation];
    }
    else
    {
        [self.toAnnotation setCoordinate:coord];
    }
    self.toAnnotationDidMove = YES;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![touch.view isKindOfClass:[UIButton class]];
}

@end
