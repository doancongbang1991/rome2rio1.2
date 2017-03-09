//
//  R2RSpriteView.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 16/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "R2RSprite.h"

@interface R2RSpriteView : NSObject

@property (strong, nonatomic) R2RSprite *sprite;
@property (strong, nonatomic) id view;

@end