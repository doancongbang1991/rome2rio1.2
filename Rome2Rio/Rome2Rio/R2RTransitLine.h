//
//  R2RTransitLine.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 5/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface R2RTransitLine : NSObject

@property (strong, nonatomic) NSString *agency;
@property (strong, nonatomic) NSString *code;
@property (nonatomic) float frequency;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *vehicle;

@end
