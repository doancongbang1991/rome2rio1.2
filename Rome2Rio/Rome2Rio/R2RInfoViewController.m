//
//  R2RInfoViewController.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 1/11/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "R2RInfoViewController.h"
#import "R2RConstants.h"
#import "R2RCurrency.h"
#import "R2RKeys.h"

@interface R2RInfoViewController ()

@property (strong, nonatomic) UIActionSheet *currencySheet;
@property (strong, nonatomic) NSArray *currencies;

@end

@implementation R2RInfoViewController

@synthesize searchManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.versionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Version %@", nil), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    [self.feedbackButton setTitle:NSLocalizedString(@"Send Feedback", nil) forState:UIControlStateNormal];
    [self.rateButton setTitle:NSLocalizedString(@"Rate App", nil) forState:UIControlStateNormal];
    
    self.currencies = [R2RConstants getAllCurrencies];
    self.currencyButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self setCurrencyButtonLabel];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self setCurrencyButtonLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self setCurrencyButton:nil];
    [self setVersionLabel:nil];
    [self setFeedbackButton:nil];
    [self setRateButton:nil];
    [self setShareEmailButton:nil];
    [super viewDidUnload];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)rateApp:(id)sender
{
    NSString *appId = [R2RKeys getAppId];

    NSURL *reviewURL = [NSURL URLWithString: [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appId]];
    
    if ([[UIApplication sharedApplication] canOpenURL:reviewURL])
    {
        [[UIApplication sharedApplication] openURL:reviewURL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not start iTunes", nil)
                                                        message:NSLocalizedString(@"Please rate rome2rio in the iTunes store", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
        R2RLog(@"App store not available");
    }
}

- (IBAction)sendFeedbackMail:(id)sender
{
    /* create mail subject */
    NSString *subject = [NSString stringWithFormat:@"iPhone App Feedback"];
    
    /* define email address */
    NSString *mail = [NSString stringWithFormat:@"feedback@rome2rio.com"];
    
    /* create the URL */
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:?to=%@&subject=%@",
                                                [mail stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                                                [subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        /* load the URL */
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not start email client", nil)
                                                        message:NSLocalizedString(@"Please send feedback to feedback@rome2rio.com", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
        R2RLog(@"Email not available");
    }
}

- (IBAction)showMasterView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareByEmail:(id)sender
{
    NSString *subject = [NSString stringWithFormat:@"%@ iPhone App", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
    
    NSString *body = [NSString stringWithFormat:@"Check out the %@ App\n%@\n\n%@\n\nPowered by http://www.rome2rio.com\n\n",
                                        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                                        [R2RConstants getAppURL],
                                        [R2RConstants getAppDescription]];
    
    /* create the URL */
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:?subject=%@&body=%@",
                                       [subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                                       [body stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        /* load the URL */
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not start email client", nil)
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
        R2RLog(@"Email not available");
    }
}

-(void)setCurrencyButtonLabel
{
    NSString *label = [NSString stringWithFormat:NSLocalizedString(@"Currency: %@", nil), [R2RConstants getUserCurrency]];
    
    [self.currencyButton setTitle:label forState:UIControlStateNormal];
    [self.currencyButton setTitle:label forState:UIControlStateHighlighted];
//    self.currencyButton.titleLabel.text = label;
}

-(void)changeCurrency:(id)sender
{
    self.currencySheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select Currency", nil)
                                                     delegate:self
                                            cancelButtonTitle:nil
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:nil];
    
    for (R2RCurrency *currency in self.currencies)
    {
        [self.currencySheet addButtonWithTitle:currency.label];
    }
    
    [self.currencySheet addButtonWithTitle:NSLocalizedString(@"cancel", nil)];
    [self.currencySheet setCancelButtonIndex:[self.currencies count]];
    
    [self.currencySheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [self.currencies count])
        return;
    
    R2RLog(@"Button %ld", (long)buttonIndex);
    R2RCurrency *currency = [self.currencies objectAtIndex:buttonIndex];
    
    if (currency != nil)
    {
        [R2RConstants setUserCurrency:currency.code];
        [self setCurrencyButtonLabel];
    }
    
    // redo search with new currency
    [self.searchManager restartSearch];
    
}

@end
