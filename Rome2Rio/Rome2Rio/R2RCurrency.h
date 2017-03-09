//
//  R2RCurrency.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 10/12/2014.
//  Copyright (c) 2014 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface R2RCurrency : NSObject

@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *label;

-(id) initWithCode: (NSString *) code label:(NSString *) label;

@end
