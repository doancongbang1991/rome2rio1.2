//
//  R2RPathEncoder.h
//  Rome2Rio
//
//  Created by Bernie Tschirren.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "R2RPath.h"

@interface R2RPathEncoder : NSObject

+ (NSString *)encode :(R2RPath *)path;
+ (R2RPath *)decode :(NSString *)data;
+ (R2RPath *)decode :(NSString *)data :(R2RPath *)path;

@end