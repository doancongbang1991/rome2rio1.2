//
//  R2RSerializer.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 6/02/13.
//  Copyright (c) 2013 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "R2RPlace.h"

@interface R2RSerializer : NSObject

+(NSString *) serializePlace:(R2RPlace *) place;
+(R2RPlace *) deserializePlace:(NSString *) placeString;

@end
