//
//  R2RAutocompleteViewController.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 31/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RAutocompleteViewController.h"
#import "R2RAutocompleteCell.h"
#import "R2RStatusButton.h"
#import "R2RMapViewController.h"
#import "R2RSerializer.h"
#import "R2RConstants.h"

@interface R2RAutocompleteViewController ()

@property (strong, nonatomic) R2RAutocomplete *autocomplete;
@property (strong, nonatomic) NSMutableArray *places;

@property (strong, nonatomic) NSMutableArray *userPlaces;
#define STORED_PLACES 50

@property (strong, nonatomic) R2RStatusButton *statusButton;

@property (strong, nonatomic) NSString *prevSearchText;

@property (nonatomic) BOOL fallbackToCLGeocoder;

@end

@implementation R2RAutocompleteViewController

@synthesize searchManager, fieldName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    self.places = [[NSMutableArray alloc] init];
    
    self.userPlaces = [self getUserPlaces];
    
    self.fallbackToCLGeocoder = NO;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] > 6.1)
    {
        self.searchBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    }
    
    CGRect frame = CGRectMake(0.0, (self.view.frame.size.height - 30), self.view.bounds.size.width, 30.0);
    if ([[UIDevice currentDevice].systemVersion floatValue] > 6.1) frame.origin.y -= 20; // temp fix to account for status bar in ios 7 until full redesign
    
    self.statusButton = [[R2RStatusButton alloc] initWithFrame:frame];
    [self.view addSubview:self.statusButton];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStatusMessage:) name:@"refreshStatusMessage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasHidden:)
                                                 name:UIKeyboardDidHideNotification object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    self.fallbackToCLGeocoder = NO;
    if ([self.fieldName isEqualToString:@"from"])
    {
        [self.searchBar setText:self.searchManager.fromText];
        [self startAutocomplete:self.searchManager.fromText];
    }
    if ([self.fieldName isEqualToString:@"to"])
    {
        [self.searchBar setText:self.searchManager.toText];
        [self startAutocomplete:self.searchManager.toText];
    }
    
    [self.searchBar becomeFirstResponder];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    [self setSearchBar:nil];
    [self setStatusView:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshStatusMessage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];

    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // number of results returned by autocomplete
    NSInteger numberOfRows = [self.places count];
    
    // Current location and Select from map
    numberOfRows += 2;
    
    // Previously Searched places (max 5)
    numberOfRows += [self.userPlaces count];
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"autocompleteCell";
    
    if (indexPath.row == [self.places count] + 1)
    {
        R2RAutocompleteCell *mapCell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        [mapCell.autocompleteImageView setHidden:NO];
        [mapCell.label setText:NSLocalizedString(@"Select on map", nil)];
        
        return mapCell;
    }
    
    // previous stored user places
    if (indexPath.row >= [self.places count] + 2)
    {
        R2RAutocompleteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserPlaceCell"];

        R2RPlace *place = [self.userPlaces objectAtIndex:(indexPath.row - [self.places count] - 2)];
        
        [cell.autocompleteImageView setHidden:YES];
        [cell.label setText:place.longName];
        [cell.label setTextColor:[R2RConstants getLightTextColor]];
        
        return cell;
    }
    
    R2RAutocompleteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (indexPath.row == [self.places count])
    {
        [cell.autocompleteImageView setHidden:NO];
        [cell.label setText:NSLocalizedString(@"Current location", nil)];
        
        return cell;
    }
    
    
    R2RPlace *place = [self.places objectAtIndex:indexPath.row];
    
    [cell.autocompleteImageView setHidden:YES];
    [cell.label setText:place.longName];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setText:self.searchBar.text];
    if (indexPath.row == [self.places count])
    {
        [self currentLocationClicked];
    }
    else if (indexPath.row == [self.places count] + 1)
    {
//        [self performSegueWithIdentifier:@"showMap" sender:self];
    }
    else if (indexPath.row >= [self.places count] + 2)
    {
        [self placeClicked:[self.userPlaces objectAtIndex:(indexPath.row - [self.places count] - 2)]];
    }
    else
    {
        [self placeClicked:[self.places objectAtIndex:indexPath.row]];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // set cell containing userPlaces as editable
    if (indexPath.row >= [self.places count] + 2)
    {
        return YES;
    }
    
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // on delete of stored user place remove object and reload table
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSInteger userPlaceIndex = indexPath.row - [self.places count] - 2;
        
        [self.userPlaces removeObjectAtIndex:userPlaceIndex];
        
        [self.tableView reloadData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showMap"])
    {
        R2RMapViewController *mapViewController = [segue destinationViewController];
        mapViewController.searchManager = self.searchManager;
        mapViewController.fieldName = self.fieldName;
    }
}

#pragma mark - Search bar delegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self startAutocomplete:searchText];
}

-(void) startAutocomplete: (NSString *) searchText
{
    if (![self.searchManager.searchStore.statusMessage isEqualToString:NSLocalizedString(@"Searching", nil)])
    {
        [self.searchManager setStatusMessage:@""];
    }
    
    if ([searchText length] < [self.prevSearchText length])
    {
        self.fallbackToCLGeocoder = NO;
    }
    
    if ([searchText length] >=2)
    {
//        self.autocomplete = [[R2RAutocomplete alloc] initWithSearchString:searchText delegate:self];
        if (self.fallbackToCLGeocoder == YES)
        {
            [self sendCLGeocodeRequest:searchText];
        }
        else
        {
            [self sendAutocompleteRequest:searchText];
        }
    }
    else
    {
        self.places = nil;
        [self.tableView reloadData];
    }
    self.prevSearchText = searchText;
    
}

//store the typed text;
-(void) setText:(NSString *) searchText;
{
    if ([self.fieldName isEqualToString:@"from"])
    {
        self.searchManager.fromText = searchText;
    }
    if ([self.fieldName isEqualToString:@"to"])
    {
        self.searchManager.toText = searchText;
    }

}

-(void) sendAutocompleteRequest:(NSString *)query
{
    self.autocomplete = [[R2RAutocomplete alloc] initWithQueryString:query delegate:self];
    [self.autocomplete sendAsynchronousRequest];
    [self performSelector:@selector(setStatusSearching:) withObject:self.autocomplete afterDelay:1.0];
}

-(void) sendCLGeocodeRequest:(NSString *)query
{
    self.autocomplete = [[R2RAutocomplete alloc] initWithQueryString:query delegate:self];
    [self.autocomplete geocodeFallback:query];
    [self performSelector:@selector(setStatusSearching:) withObject:self.autocomplete afterDelay:1.0];
}

-(void) setStatusSearching:(R2RAutocomplete *) autocomplete
{
    if (self.autocomplete == autocomplete)
    {
        if (self.autocomplete.responseCompletionState != r2rCompletionStateResolved && self.autocomplete.responseCompletionState != r2rCompletionStateError && self.autocomplete.responseCompletionState != r2rCompletionStateLocationNotFound)
        {
            [self.searchManager setStatusMessage:NSLocalizedString(@"Searching", nil)];
        }
    }
}

-(void) currentLocationClicked
{
    if ([self.fieldName isEqualToString:@"from"])
    {
        [self.searchManager setFromWithCurrentLocation];
    }
    if ([self.fieldName isEqualToString:@"to"])
    {
        [self.searchManager setToWithCurrentLocation];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) placeClicked:(R2RPlace *) place;
{
    if ([self.fieldName isEqualToString:@"from"])
    {
        [self.searchManager setFromPlace:place];
    }
    if ([self.fieldName isEqualToString:@"to"])
    {
        [self.searchManager setToPlace:place];
    }
    
    // store place
    [self setUserPlace:place];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([self.searchBar.text length] <= 1) return;
    
    //restart search if not currently searching or idle
    if (self.autocomplete.responseCompletionState == r2rCompletionStateError || self.autocomplete.responseCompletionState == r2rCompletionStateLocationNotFound)
    {
        [self startAutocomplete:self.searchBar.text];
    }
}

#pragma mark - autocomplete delegate

-(void)autocompleteResolved:(R2RAutocomplete *)autocomplete
{
    if (self.autocomplete == autocomplete)
    {
        if (autocomplete.responseCompletionState == r2rCompletionStateResolved)
        {
            if ([autocomplete.geocodeResponse.places count] > 0)
            {
                [self.searchManager setStatusMessage:@""];
                self.places = self.autocomplete.geocodeResponse.places;
                [self.tableView reloadData];
            }
            else
            {
                if (self.fallbackToCLGeocoder == NO)
                {
                    self.fallbackToCLGeocoder = YES;
                    [self sendCLGeocodeRequest:autocomplete.query];
                }
            }
        }
        else if (autocomplete.responseCompletionState == r2rCompletionStateLocationNotFound) //state only returned from geocodeFallback
        {
            [self.searchManager setStatusMessage:autocomplete.responseMessage];
            self.places = self.autocomplete.geocodeResponse.places;
            [self.tableView reloadData];
        }
        else
        {
            //if response not resolved send off a single CLGeocode request
            [self sendCLGeocodeRequest:autocomplete.query];
        }
    }
}

-(void) refreshStatusMessage:(NSNotification *) notification
{
    [self.statusButton setTitle:self.searchManager.searchStore.statusMessage forState:UIControlStateNormal];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [self setStatusBarPositionWithKeyboardHeight:kbSize.height];
    
    CGRect tableViewFrame = self.tableView.frame;
    
    if (tableViewFrame.size.height >=  self.view.frame.size.height - self.searchBar.frame.size.height)
    {
        tableViewFrame.size.height -= kbSize.height;
    }
    [self.tableView setFrame:tableViewFrame];
}

// Called when the UIKeyboardDidHideNotification is sent
// Using DidHide instead of WillHide so it doesn't do anything while the modal view is being dismissed
- (void) keyboardWasHidden:(NSNotification*)aNotification
{
    [self setStatusBarPositionWithKeyboardHeight:0];
    
    CGRect tableViewFrame = self.tableView.frame;
    
    if (tableViewFrame.size.height <  self.view.frame.size.height - self.searchBar.frame.size.height)
    {
        tableViewFrame.size.height = self.view.frame.size.height - self.searchBar.frame.size.height;
    }
    
    [self.tableView setFrame:tableViewFrame];
}

- (void) setStatusBarPositionWithKeyboardHeight:(float) keyboardHeight
{
    CGRect frame = self.statusButton.frame;
    float offset = 30;
    if ([[UIDevice currentDevice].systemVersion floatValue] > 6.1) offset = 50; // temp fix to account for status bar in ios 7 until full redesign

    frame.origin.y = self.view.frame.size.height - keyboardHeight - offset;
    
    [self.statusButton setFrame:frame];
}

// record users last 5 autocomplete places
- (void) setUserPlace:(R2RPlace *) place
{
    
    NSMutableArray *userPlaces = nil;
    
    if ([self.userPlaces count] == 0)
    {
        userPlaces = [[NSMutableArray alloc] initWithCapacity:1]; // the array will end up being used with capacity 5 but only 1 is ever added at a time
    }
    else
    {
        userPlaces = [[NSMutableArray alloc] initWithArray:self.userPlaces];
    }
    
    bool placeFound = NO;
    NSInteger placeIndex = 0;
    
    // check stored palces for current place
    for (R2RPlace *userPlace in userPlaces)
    {
        if ([userPlace.longName isEqualToString:place.longName])
        {
            placeFound = YES;
            break;
        }
        placeIndex++;
    }
    
    // if userPlaces contain current place, reorder array
    if (placeFound)
    {
        // if place found move to start of array
        [userPlaces removeObjectAtIndex:placeIndex];
        [userPlaces insertObject:place atIndex:0];
    }
    // otherwise add to start of list
    else
    {
        // only store 5 places so remove last place to make room for new place
        if ([userPlaces count] > STORED_PLACES - 1)
        {
            [userPlaces removeLastObject];
        }
        
        // add to start
        [userPlaces insertObject:place atIndex:0];
    }
    
    NSMutableArray *userPlacesToStore = [[NSMutableArray alloc] initWithCapacity:[userPlaces count]];
    
    for (R2RPlace *userPlace in userPlaces)
    {
        NSString *placeString = [R2RSerializer serializePlace:userPlace];
        [userPlacesToStore addObject:placeString];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *r2rUserPlacesKey = @"R2RUserPlaces";
    
    // store users last 5 autocomplete places
    [userDefaults setObject:userPlacesToStore forKey:r2rUserPlacesKey];
}

-(NSMutableArray *) getUserPlaces
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *r2rUserPlacesKey = @"R2RUserPlaces";
    
    NSArray *storedUserPlaces = [userDefaults arrayForKey:r2rUserPlacesKey];
    
    NSMutableArray *userPlaces = [[NSMutableArray alloc] initWithCapacity:[storedUserPlaces count]];
    
    for (NSString *placeString in storedUserPlaces)
    {
        R2RPlace *place = [R2RSerializer deserializePlace:placeString];
        [userPlaces addObject:place];
    }
        
    return userPlaces;
}

@end
