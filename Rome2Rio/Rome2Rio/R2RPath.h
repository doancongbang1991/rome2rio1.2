//
//  R2RPath.h
//  Rome2Rio
//
//  Created by Bernie Tschirren.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "R2RPosition.h"

@interface R2RPath : NSObject
{
	NSMutableArray *positions;
}

@property (strong, nonatomic, readonly) NSArray *positions;

-(void) addPosition:(R2RPosition *)position;

@end