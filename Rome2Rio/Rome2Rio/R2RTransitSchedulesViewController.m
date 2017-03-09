//
//  R2RTransitSchedulesViewController.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 7/02/13.
//  Copyright (c) 2013 Rome2Rio. All rights reserved.
//

#import "R2RTransitSchedulesViewController.h"

@interface R2RTransitSchedulesViewController ()

//@property (nonatomic) bool webViewIsLoading;

@end

@implementation R2RTransitSchedulesViewController

@synthesize schedulesURL;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.webView setDelegate:self];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(navigateBack)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.schedulesURL];
    
    //Load the request in the UIWebView.
    [self.webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setBack:nil];
    [self setForward:nil];
    [self setRefresh:nil];
    [self setOpenExternal:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

#pragma mark UIWebViewDelegate protocol
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [self.activityIndicator startAnimating];
    
//    self.webViewIsLoading = YES;
    
    [self updateButtons];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.activityIndicator stopAnimating];
    [self updateButtons];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.activityIndicator stopAnimating];
    UIAlertView* alertView = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:[error localizedDescription] delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
    [self updateButtons];
}

-(void)updateButtons
{
    self.forward.enabled = self.webView.canGoForward;
    self.back.enabled = self.webView.canGoBack;
}

- (IBAction)returnToSearch:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)openInBrowser:(id)sender
{   
    [[UIApplication sharedApplication] openURL:self.schedulesURL];
}

- (void) navigateBack
{
    [self.navigationController popViewControllerAnimated:true];
}

@end
