//
//  R2RKeys.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 19/12/2013.
//  Copyright (c) 2013 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface R2RKeys : NSObject

@property NSDictionary *apiProperties;

+(NSString *) getAppId;
+(NSString *) getAppKey;

+(NSDictionary *) getApiProperties;
+(NSString *) getApiPlistPath;

@end
