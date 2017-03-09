//
//  R2RMasterViewController.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 6/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RMasterViewController.h"
#import "R2RResultsViewController.h"
#import "R2RMasterViewStatusButton.h"
#import "R2RInfoViewController.h"
#import "R2RSearchButton.h"

#import "R2RConstants.h"

@interface R2RMasterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *fromTextField;
@property (weak, nonatomic) IBOutlet UITextField *toTextField;

@property (weak, nonatomic) IBOutlet UIView *headerBackground;
@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@property (weak, nonatomic) IBOutlet R2RSearchButton *searchButton;
@property (strong, nonatomic) R2RMasterViewStatusButton *statusButton;

@property (nonatomic) BOOL textFieldDidClear;

- (IBAction)searchTouchUpInside:(id)sender;
- (IBAction)showInfoView:(id)sender;

@end

@implementation R2RMasterViewController

@synthesize searchStore, fromTextField, toTextField;

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Search", nil);
    
    self.headerBackground.layer.cornerRadius = 8;
    
    //adjust text boc size above default 31
    CGRect frame = self.fromTextField.frame;
    frame.size.height = 40;
    self.fromTextField.frame = frame;
    frame = self.toTextField.frame;
    frame.size.height = 40;
    self.toTextField.frame = frame;
    
    self.fromTextField.placeholder = NSLocalizedString(@"Origin", nil);
    self.toTextField.placeholder = NSLocalizedString(@"Destination", nil);
    [self.searchButton setTitle:NSLocalizedString(@"Search", nil) forState:UIControlStateNormal];

    [self.view setBackgroundColor:[R2RConstants getBackgroundColor]];

    self.statusButton = [[R2RMasterViewStatusButton alloc] initWithFrame:CGRectMake(0.0, (self.view.frame.size.height-30), self.view.frame.size.width-30, 30.0)];

    [self.view addSubview:self.statusButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFromTextField:) name:@"refreshFromTextField" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshToTextField:) name:@"refreshToTextField" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStatusMessage:) name:@"refreshStatusMessage" object:nil];
}

- (void)viewDidUnload
{
    [self setFromTextField:nil];
    [self setToTextField:nil];
    [self setHeaderBackground:nil];
    [self setHeaderImage:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshFromTextField" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshToTextField" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshStatusMessage" object:nil];
    
    [self setSearchButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ((textField == self.fromTextField) || (textField == self.toTextField))
    {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showSearchResults"])
    {
        R2RResultsViewController *resultsViewController = [segue destinationViewController];
        resultsViewController.searchManager = self.searchManager;
        resultsViewController.searchStore = self.searchStore;
    }
    
    if ([[segue identifier] isEqualToString:@"showAutocomplete"])
    {
        R2RAutocompleteViewController *autocompleteViewController = (R2RAutocompleteViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        autocompleteViewController.searchManager = self.searchManager;
        autocompleteViewController.fieldName = sender;
    }
    
    if ([[segue identifier] isEqualToString:@"showInfo"])
    {
        R2RInfoViewController *infoViewController = [segue destinationViewController];
        infoViewController.searchManager = self.searchManager;
    }
}

- (IBAction)searchTouchUpInside:(id)sender
{
    //If not geocoding or searching and there is no searchResponse restart process
    [self.searchManager restartSearchIfNoResponse];
    
    if ([self.searchManager canShowSearchResults])
        [self performSegueWithIdentifier:@"showSearchResults" sender:self];

}

// Only for app url deeplinks
-(void)setFromTextFieldText:(NSString *)text
{
    self.fromTextField.text = text;
}

// Only for app url deeplinks
-(void)setToTextFieldText:(NSString *)text
{
    self.toTextField.text = text;
}

-(void) refreshFromTextField:(NSNotification *) notification
{
    self.fromTextField.text = self.searchStore.fromPlace.longName;
}

-(void) refreshToTextField:(NSNotification *) notification
{
    self.toTextField.text = self.searchStore.toPlace.longName;
}

-(void) refreshStatusMessage:(NSNotification *) notification
{
    [self setStatusMessage:self.searchStore.statusMessage];
}

-(void) setStatusMessage: (NSString *) message
{
    [self.statusButton setTitle:message forState:UIControlStateNormal];
}

- (IBAction)showInfoView:(id)sender
{
    [self performSegueWithIdentifier:@"showInfo" sender:self];
}

-(void)autocompleteResolved:(R2RAutocomplete *)autocomplete
{
    if ([autocomplete.query isEqualToString:self.fromTextField.text])
    {
        if ([autocomplete.geocodeResponse.places count] > 0)
        {
            [self.searchManager setFromPlace:[autocomplete.geocodeResponse.places objectAtIndex:0]];
        }
    }
    
    if ([autocomplete.query isEqualToString:self.toTextField.text])
    {
        if ([autocomplete.geocodeResponse.places count] > 0)
        {
            [self.searchManager setToPlace:[autocomplete.geocodeResponse.places objectAtIndex:0]];
        }
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (!self.textFieldDidClear)
    {
        if (textField == self.fromTextField)
        {
            [self performSegueWithIdentifier:@"showAutocomplete" sender:@"from"];
        }
        if (textField == self.toTextField)
        {
            [self performSegueWithIdentifier:@"showAutocomplete" sender:@"to"];
        }
    }
    self.textFieldDidClear = NO;
    return NO;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.fromTextField)
    {
        [self.searchManager setFromPlace:nil];
        self.searchManager.fromText = nil;
    }
    if (textField == self.toTextField)
    {
        [self.searchManager setToPlace:nil];
        self.searchManager.toText = nil;
    }
    self.textFieldDidClear = YES;
    return YES;
}

@end
