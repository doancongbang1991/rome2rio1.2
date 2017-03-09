//
//  R2RFlightTicket.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 4/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface R2RFlightTicket : NSObject

@property (strong, nonatomic) NSString *name;
@property (nonatomic) float price;
@property (strong, nonatomic) NSString *currency;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSURL *url;

@end
