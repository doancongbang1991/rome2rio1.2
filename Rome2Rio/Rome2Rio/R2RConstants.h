//
//  R2RConstants.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 29/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface R2RConstants : NSObject

+(NSString *) getUserId;
+(void) setUserCurrency:(NSString *)currencyCode;
+(NSString *) getUserCurrency;
+(NSString *) getAppURL;
+(NSString *) getAppDescription;

+(UIImage *) getMasterViewBackgroundImage;
+(UIImage *) getMasterViewLogo;

+(MKCoordinateRegion) getStartMapRegion;

+(float) getTableWidth;

+(NSString *) getIconSpriteFileName;
+(NSString *) getConnectionsImageFileName;
+(NSString *) getMyLocationSpriteFileName;

+(CGRect) getConnectionIconRect;
+(CGRect) getHopIconRect;
+(CGRect) getMyLocationIconRect;
+(CGRect) getExternalLinkWhiteIconRect;
+(CGRect) getExternalLinkPinkIconRect;

+(CGRect) getRouteFlightSpriteRect;
+(CGRect) getRouteHelicopterSpriteRect;
+(CGRect) getRouteTrainSpriteRect;
+(CGRect) getRouteTramSpriteRect;
+(CGRect) getRouteCablecarSpriteRect;
+(CGRect) getRouteBusSpriteRect;
+(CGRect) getRouteFerrySpriteRect;
+(CGRect) getRouteCarSpriteRect;
+(CGRect) getRouteTaxiSpriteRect;
+(CGRect) getRouteRideshareSpriteRect;
+(CGRect) getRouteWalkSpriteRect;
+(CGRect) getRouteAnimalSpriteRect;
+(CGRect) getRouteBikeSpriteRect;
+(CGRect) getRouteUnknownSpriteRect;

+(UIColor *) getBackgroundColor;
+(UIColor *) getCellColor;
+(UIColor *) getExpandedCellColor;
+(UIColor *) getLightTextColor;
+(UIColor *) getDarkTextColor;
+(UIColor *) getButtonHighlightColor;
+(UIColor *) getButtonHighlightDarkerColor;
+(UIColor *) getFlightColor;
+(UIColor *) getBusColor;
+(UIColor *) getTrainColor;
+(UIColor *) getFerryColor;
+(UIColor *) getDriveColor;
+(UIColor *) getTaxiColor;
+(UIColor *) getBikeColor;
+(UIColor *) getUnknownColor;
+(UIColor *) getWalkColor;

+(NSArray *) getAllCurrencies;

#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define MAX_FLIGHT_STOPS 5
#define MAX_ICONS 3

@end
