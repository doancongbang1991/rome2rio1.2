//
//  R2RAppDelegate.m
//  R2RApp
//
//  Created by Ash Verdoorn on 6/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RAppDelegate.h"
#import "R2RMasterViewController.h"

#import "R2RSearchStore.h"
#import "R2RSearchManager.h"
#import "R2RAppRater.h"


@interface R2RAppDelegate()

@property (strong, nonatomic) R2RAppRater *appRater;

@end

@implementation R2RAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] > 6.1)
    {
        [navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    }
    
    R2RMasterViewController *firstViewController = (R2RMasterViewController *)[[navigationController viewControllers] objectAtIndex:0];
    
    R2RSearchStore *searchStore = [[R2RSearchStore alloc] init];
    
    R2RSearchManager *searchManager = [[R2RSearchManager alloc] init];
    searchManager.searchStore = searchStore;
    
    firstViewController.searchManager = searchManager;
    firstViewController.searchStore = searchStore;
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (!self.appRater)
    {
        self.appRater = [[R2RAppRater alloc] init];
    }
    [self.appRater appStarted];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // If loading from apple maps
    if ([MKDirectionsRequest isDirectionsRequestURL:url])
    {
        MKDirectionsRequest *directionsInfo = [[MKDirectionsRequest alloc] initWithContentsOfURL:url];
        
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        
        [navigationController dismissViewControllerAnimated:NO completion:nil];
        [navigationController popToRootViewControllerAnimated:NO];
        
        R2RMasterViewController *firstViewController = (R2RMasterViewController *)[[navigationController viewControllers] objectAtIndex:0];
        
        if (directionsInfo.source.isCurrentLocation)
        {
            [firstViewController.searchManager setFromWithCurrentLocation];
        }
        else
        {
            CLLocationCoordinate2D sourceCoord = directionsInfo.source.placemark.coordinate;
            if (CLLocationCoordinate2DIsValid(sourceCoord))
            {
                [firstViewController.searchManager setFromWithMapLocation:sourceCoord mapScale:50.0];
            }
        }
        
        if (directionsInfo.destination.isCurrentLocation)
        {
            [firstViewController.searchManager setToWithCurrentLocation];
        }
        else
        {
            CLLocationCoordinate2D destCoord = directionsInfo.destination.placemark.coordinate;
            if (CLLocationCoordinate2DIsValid(destCoord))
            {
                [firstViewController.searchManager setToWithMapLocation:destCoord mapScale:50.0];
            }
        }
        
        if ([firstViewController.searchManager canShowSearchResults])
        {
            [firstViewController performSegueWithIdentifier:@"showSearchResults" sender:self];
        }
        
        return YES;
    }
    
    // if loading from rome2rio website
    if ([[url host] rangeOfString:@"rome2rio.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        
        [navigationController dismissViewControllerAnimated:NO completion:nil];
        [navigationController popToRootViewControllerAnimated:NO];
        
        R2RMasterViewController *firstViewController = (R2RMasterViewController *)[[navigationController viewControllers] objectAtIndex:0];
        
        NSRange range = [[url path] rangeOfString:@"/s/"];
        
        NSString *queriesString = [[url path] substringFromIndex: (range.location + range.length)];
        
        NSArray *queries = [queriesString componentsSeparatedByString:@"/"];
        
        if ([queries count] > 0)
        {
            [firstViewController setFromTextFieldText:[queries objectAtIndex:0]];
            R2RAutocomplete *fromAutocomplete = [[R2RAutocomplete alloc] initWithQueryString:[queries objectAtIndex:0] delegate:firstViewController];
            [fromAutocomplete sendAsynchronousRequest];
        }
        if ([queries count] > 1)
        {
            [firstViewController setToTextFieldText:[queries objectAtIndex:1]];
            R2RAutocomplete *toAutocomplete = [[R2RAutocomplete alloc] initWithQueryString:[queries objectAtIndex:1] delegate:firstViewController];
            [toAutocomplete sendAsynchronousRequest];
        }
       
        return YES;
    }
    
    
    return NO;
}

@end
