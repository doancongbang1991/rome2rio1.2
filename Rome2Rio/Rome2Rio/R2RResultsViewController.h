//
//  R2RResultsViewController.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 6/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "R2RSearchStore.h"
#import "R2RSearchManager.h"
#import "R2RTableView.h"
#import "R2RSearchButton.h"

@interface R2RResultsViewController : UIViewController <UIScrollViewDelegate, R2RTableViewDelegate, UITableViewDataSource, MKMapViewDelegate>

@property (strong, nonatomic) R2RSearchManager *searchManager;
@property (strong, nonatomic) R2RSearchStore *searchStore;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet R2RSearchButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *resizeMapButton;

- (IBAction)returnToSearch:(id)sender;
- (IBAction)resolveLocation:(id)sender;
- (IBAction)resizeMap:(id)sender;

@end
