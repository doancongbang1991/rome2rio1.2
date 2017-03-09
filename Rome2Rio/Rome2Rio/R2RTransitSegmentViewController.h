//
//  R2RTransitSegmentViewController.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 29/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "R2RSearchManager.h"
#import "R2RSearchStore.h"
#import "R2RTableView.h"
#import "R2RSearchButton.h"

@interface R2RTransitSegmentViewController : UIViewController <UIScrollViewDelegate, R2RTableViewDelegate, UITableViewDataSource, MKMapViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) R2RSearchManager *searchManager;
@property (strong, nonatomic) R2RSearchStore *searchStore;
@property (strong, nonatomic) R2RRoute *route;
@property (strong, nonatomic) R2RTransitSegment *transitSegment;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet R2RSearchButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *resizeMapButton;

- (IBAction)returnToSearch:(id)sender;
- (IBAction)resolveLocation:(id)sender;
- (IBAction)resizeMap:(id)sender;

@end
