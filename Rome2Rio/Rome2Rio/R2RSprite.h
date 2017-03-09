//
//  R2RSprite.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 29/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface R2RSprite : NSObject

@property (nonatomic) CGPoint offset;
@property (nonatomic) CGSize size;
@property (strong, nonatomic) NSString *path;

-(id) initWithPath :(NSString *)path :(CGPoint)offset :(CGSize)size;

-(UIImage *) getSprite :(UIImage *)image;

@end
