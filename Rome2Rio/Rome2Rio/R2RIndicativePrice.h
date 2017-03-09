//
//  R2RIndicativePrice.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 24/09/2014.
//  Copyright (c) 2014 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface R2RIndicativePrice : NSObject

@property (nonatomic) float price;
@property (strong, nonatomic) NSString *currency;
@property (nonatomic) float nativePrice;
@property (strong, nonatomic) NSString *nativeCurrency;
@property (nonatomic) bool isFreeTransfer;

@end
