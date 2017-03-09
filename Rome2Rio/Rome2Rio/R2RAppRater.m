//
//  R2RAppRater.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 3/12/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//


#import "R2RAppRater.h"
#import "R2RKeys.h"

static NSInteger usesUntilPrompt = 2;

//TODO remove small testing values
//static float daysUntilPrompt = 0.001;
//static float daysUntilReminder = 0.001;
static NSInteger daysUntilPrompt = 1;
static NSInteger daysUntilReminder = 1;

NSString *const kR2RAppName                 = @"R2RAppName";
NSString *const kR2RFirstUseTimeInterval    = @"R2RFirstUseTimeInterval";
NSString *const kR2RUseCount                = @"R2RUseCount";
NSString *const kR2RDidRate                 = @"R2RDidRate";
NSString *const kR2RDeclinedToRate          = @"R2RDeclinedToRate";
NSString *const kR2RReminderTimeInterval    = @"R2RReminderTimeInterval";

@implementation R2RAppRater

-(void) appStarted
{
    [self incrementUse];
    
    if ([self canShowRatePrompt])
    {
        [self showRatePrompt];
    }
}

-(void) incrementUse
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //can add version number if rating is desired for each version
    
    NSString *appName = [userDefaults stringForKey:kR2RAppName];
    
    if (appName == nil)
    {
        appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
        [userDefaults setObject:appName forKey:kR2RAppName];
        [userDefaults setDouble:[[NSDate date] timeIntervalSince1970] forKey:kR2RFirstUseTimeInterval];
        [userDefaults setInteger:1 forKey:kR2RUseCount];
        [userDefaults setBool:NO forKey:kR2RDidRate];
        [userDefaults setBool:NO forKey:kR2RDeclinedToRate];
        [userDefaults setDouble:0.0 forKey:kR2RReminderTimeInterval];
    }
    else
    {
        //make sure a date is set
        NSTimeInterval timeInterval = [userDefaults doubleForKey:kR2RFirstUseTimeInterval];
		if (timeInterval == 0)
		{
			timeInterval = [[NSDate date] timeIntervalSince1970];
			[userDefaults setDouble:timeInterval forKey:kR2RFirstUseTimeInterval];
		}
        
        long count = [userDefaults integerForKey:kR2RUseCount];
		count++;
		[userDefaults setInteger:count forKey:kR2RUseCount];

    }
    
    [userDefaults synchronize];
}

-(bool) canShowRatePrompt
{
//    if (DEBUG)
//		return YES;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    bool userDidRate = [userDefaults boolForKey:kR2RDidRate];
    R2RLog(@"%i", userDidRate);
    if (userDidRate) return NO;
    
    bool userDeclinedToRate = [userDefaults boolForKey:kR2RDeclinedToRate];
    R2RLog(@"%i", userDeclinedToRate);
    if (userDeclinedToRate) return NO;
    
    long useCount = [userDefaults integerForKey:kR2RUseCount];
    R2RLog(@"%ld", useCount);
	if (useCount < usesUntilPrompt) return NO;

    NSTimeInterval firstUseTimeInterval = [userDefaults doubleForKey:kR2RFirstUseTimeInterval];
    NSTimeInterval timeIntervalUntilNow = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval timeUntilPrompt = 60 * 60 * 24 * daysUntilPrompt;
    R2RLog(@"%f\t%f\t%f\t%f", firstUseTimeInterval, timeUntilPrompt, timeIntervalUntilNow, (firstUseTimeInterval + timeUntilPrompt) - timeIntervalUntilNow);
    if (firstUseTimeInterval + timeUntilPrompt > timeIntervalUntilNow) return NO;
    
    NSTimeInterval reminderTimeInterval = [userDefaults doubleForKey:kR2RReminderTimeInterval];
    NSTimeInterval timeUntilReminder = 60 * 60 * 24 * daysUntilReminder;
    R2RLog(@"%f\t%f\t%f\t%f", reminderTimeInterval, timeUntilReminder, timeIntervalUntilNow, (reminderTimeInterval + timeUntilReminder) - timeIntervalUntilNow);
    if (reminderTimeInterval + timeUntilReminder > timeIntervalUntilNow) return NO;
    
    // return yes if all conditions are passed
    return YES;
}

-(void) showRatePrompt
{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Rate %@", nil), appName];
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"If you enjoy using %@, please take a moment to rate it", nil), appName];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"No thanks", nil)
                                              otherButtonTitles:title, NSLocalizedString(@"Remind me later", nil), nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	switch (buttonIndex)
    {
		case 0:
            // "No Thanks"
            [userDefaults setBool:YES forKey:kR2RDeclinedToRate];
            break;
            
		case 1:
			// "Rate App"
            [userDefaults setBool:YES forKey:kR2RDidRate];
			[self rateApp];
			break;
            
		case 2:
        	// "Remind me later"
			[userDefaults setDouble:[[NSDate date] timeIntervalSince1970] forKey:kR2RReminderTimeInterval];
			break;
            
        default:
			break;
	}
    
    [userDefaults synchronize];
}

-(void) rateApp
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

@end
