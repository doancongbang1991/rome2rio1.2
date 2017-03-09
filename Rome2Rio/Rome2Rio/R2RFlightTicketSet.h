//
//  R2RFlightTicketSet.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 4/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "R2RFlightTicket.h"

@interface R2RFlightTicketSet : NSObject

@property (strong, nonatomic) NSString *sCode;
@property (strong, nonatomic) NSString *tCode;

@property (strong, nonatomic) NSMutableArray *tickets;

@end
