//
//  R2RMapViewController.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 21/11/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "R2RSearchManager.h"

@interface R2RMapViewController : UIViewController <UIScrollViewDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) R2RSearchManager *searchManager;
@property (strong, nonatomic) NSString *fieldName;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)resolveLocation:(id)sender;
- (IBAction)returnToSearch:(id)sender;

@end
