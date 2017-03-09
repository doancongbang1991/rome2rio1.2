//
//  R2RSpriteStore.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 16/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "R2RSprite.h"

@interface R2RSpriteStore : NSObject

-(UIImage *) loadImage: (NSString *)path; //async load image
-(void) setSpriteInButton: (R2RSprite *)sprite button:(id) button;
-(void) setSpriteInView: (R2RSprite *)sprite view:(UIImageView *) view;

@end


