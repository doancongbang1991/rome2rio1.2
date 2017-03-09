//
//  R2RSpriteCache.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 13/11/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "R2RSprite.h"

@interface R2RSpriteCache : NSObject

-(id) init;
-(R2RSprite *) getSprite :(NSString *)path :(CGPoint)offset :(CGSize)size;

@end
