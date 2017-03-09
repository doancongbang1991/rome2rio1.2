//
//  R2RSprite.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 29/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RSprite.h"

@interface R2RSprite ()

@property (strong, nonatomic) UIImage *sprite;

@end


@implementation R2RSprite

@synthesize path = _path;
@synthesize offset = _offset;
@synthesize size = _size;

-(id)initWithPath:(NSString *)path :(CGPoint)offset :(CGSize)size
{
    self = [super init];
    if (self)
    {
        self.path = path;
        self.offset = offset;
        self.size = size;
    }
    
    return self;
}

-(UIImage *) getSprite:(UIImage *)image
{
    if (self.sprite == nil)
    {
        CGRect rect = CGRectMake(self.offset.x, self.offset.y, self.size.width, self.size.height);
        
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
        
        self.sprite = [UIImage imageWithCGImage:imageRef];
        
        CGImageRelease(imageRef);
    }
    
    return self.sprite;
}

@end
