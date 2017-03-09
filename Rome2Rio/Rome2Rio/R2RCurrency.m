//
//  R2RCurrency.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 10/12/2014.
//  Copyright (c) 2014 Rome2Rio. All rights reserved.
//

#import "R2RCurrency.h"

@implementation R2RCurrency

@synthesize code, label;

-(id)initWithCode:(NSString *)_code label:(NSString *)_label
{
    self = [super init];
    if (self != nil)
    {
        self.label = _label;
        self.code = _code;
    }
    
    return self;
}

@end
