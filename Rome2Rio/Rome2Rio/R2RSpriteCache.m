//
//  R2RSpriteCache.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 13/11/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RSpriteCache.h"

@interface R2RSpriteCache ()

@property (strong, nonatomic) NSMutableArray *sprites;

@end


@implementation R2RSpriteCache

-(id) init
{
    self = [super init];
    if (self != nil)
    {
        self.sprites = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(R2RSprite *) getSprite :(NSString *)path :(CGPoint)offset :(CGSize)size
{
    for (R2RSprite *sprite in self.sprites)
    {
        if ([sprite.path isEqualToString:path] && CGPointEqualToPoint(sprite.offset, offset) && CGSizeEqualToSize(sprite.size, size))
        {
            return sprite;
        }
    }
    
    R2RSprite *sprite = [[R2RSprite alloc] initWithPath:path :offset :size];
    [self.sprites addObject:sprite];
    
    return sprite;
}

@end
