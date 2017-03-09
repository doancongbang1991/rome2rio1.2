//
//  R2RAirport.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 4/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "R2RPosition.h"

@interface R2RAirport : NSObject

@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) R2RPosition *pos;

@end
