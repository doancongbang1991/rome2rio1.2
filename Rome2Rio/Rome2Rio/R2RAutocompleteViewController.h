//
//  R2RAutocompleteViewController.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 31/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "R2RAutocomplete.h"
#import "R2RSearchManager.h"

@interface R2RAutocompleteViewController : UIViewController <UIScrollViewDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDataSource, R2RAutocompleteDelegate>

@property (strong, nonatomic) R2RSearchManager *searchManager;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString *fieldName;
@property (strong, nonatomic) UIView *statusView;

@end
