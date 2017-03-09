//
//  R2RInfoViewController.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 1/11/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "R2RSearchButton.h"
#import "R2RSearchManager.h"

@interface R2RInfoViewController : UIViewController <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet R2RSearchButton *feedbackButton;
@property (weak, nonatomic) IBOutlet R2RSearchButton *rateButton;
@property (weak, nonatomic) IBOutlet R2RSearchButton *shareEmailButton;
@property (weak, nonatomic) IBOutlet R2RSearchButton *currencyButton;

@property (strong, nonatomic) R2RSearchManager *searchManager;

- (IBAction)sendFeedbackMail:(id)sender;
- (IBAction)rateApp:(id)sender;
- (IBAction)showMasterView:(id)sender;
- (IBAction)shareByEmail:(id)sender;
- (IBAction)changeCurrency:(id)sender;

@end
