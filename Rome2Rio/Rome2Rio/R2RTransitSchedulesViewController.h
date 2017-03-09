//
//  R2RTransitSchedulesViewController.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 7/02/13.
//  Copyright (c) 2013 Rome2Rio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface R2RTransitSchedulesViewController : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *back;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forward;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refresh;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *openExternal;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) NSURL *schedulesURL;

- (IBAction)returnToSearch:(id)sender;
- (IBAction)openInBrowser:(id)sender;

- (void)updateButtons;

@end
