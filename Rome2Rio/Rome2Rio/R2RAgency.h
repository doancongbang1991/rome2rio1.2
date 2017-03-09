//
//  R2RAgency.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 5/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface R2RAgency : NSObject

@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *iconPath;
@property (nonatomic) CGPoint iconOffset;
@property (nonatomic) CGSize iconSize;

@end
