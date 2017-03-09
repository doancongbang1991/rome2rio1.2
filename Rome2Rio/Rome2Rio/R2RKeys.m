//
//  R2RKeys.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 19/12/2013.
//  Copyright (c) 2013 Rome2Rio. All rights reserved.
//

#import "R2RKeys.h"

@implementation R2RKeys

static NSString *appIdKey = @"App ID";
static NSString *appKeyKey = @"Key";

+(NSString *) getAppId {
    return [[self getApiProperties] objectForKey:appIdKey];
}
+(NSString *) getAppKey {
    return [[self getApiProperties] objectForKey:appKeyKey];
}

+(NSDictionary *) getApiProperties {
    static NSDictionary *apiProperties = nil;
    
    if (apiProperties == nil) {
        apiProperties = [[NSDictionary alloc] initWithContentsOfFile:[self getApiPlistPath]];
    }
    
    return apiProperties;
}

+(NSString *) getApiPlistPath {
    NSString *apiPlistPath = [[NSBundle mainBundle] pathForResource:@"Rome2Rio-API" ofType:@"plist"];
    
    if (apiPlistPath == nil) {
        [NSException raise:@"API Plist not found" format:@"Please rename Rome2Rio-API.plist.example to Rome2Rio-API.plist and fill in using the API information you've received from http://www.rome2rio.com/documentation/signup"];
    }
    
    return apiPlistPath;
}

@end
