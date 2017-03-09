//
//  R2RFlightGroup.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 9/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface R2RFlightGroup : NSObject

@property NSInteger hops;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *flights;

-(id) initWithHops: (NSInteger) hops;

@end
