//
//  R2RStop.h
//  R2RApp
//
//  Created by Ash Verdoorn on 12/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "R2RPosition.h"

@interface R2RStop : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) R2RPosition *pos;
@property (strong, nonatomic) NSString *kind;
@property (strong, nonatomic) NSString *code;

@end
