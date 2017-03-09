//
//  R2RSpriteStore.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 16/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RSpriteStore.h"
#import "R2RImageLoader.h"
#import "R2RSpriteView.h"

@interface R2RSpriteStore() <R2RImageLoaderDelegate>

@property (strong, nonatomic) NSMutableDictionary *imageStore; //key path, object image
@property (strong, nonatomic) NSMutableDictionary *imageLoaders; //store of loaders currently downloading images. key path, object imageLoader
@property (strong, nonatomic) NSMutableArray *spriteViews; //store of views awaiting images currently downloading images. key path, object view array

@end

@implementation R2RSpriteStore

-(id)init
{
    self = [super init];
    
    if (self != nil)
    {
        self.imageStore = [[NSMutableDictionary alloc] init];
        self.imageLoaders = [[NSMutableDictionary alloc] init];
        self.spriteViews = [[NSMutableArray alloc] init];
    }
    return self;
}

-(UIImage *)loadImage:(NSString *)path
{
    UIImage *image = [self.imageStore objectForKey:path];
    if (!image && [path length] > 0)
    {
        NSURL *urlPath = [[NSURL alloc] initWithString:path];
        if ([[urlPath pathComponents] count] == 1) //local file
        {
            image = [UIImage imageNamed:path];
            [self.imageStore setObject:image forKey:path];
            return image;
        }
                
        R2RImageLoader *loader = [self.imageLoaders objectForKey:path];
        if (!loader)
        {
            loader = [[R2RImageLoader alloc] initWithPath:path];
            loader.delegate = self;
            [loader sendAsynchronousRequest];
            [self.imageLoaders setObject:loader forKey:path];
        }
    }
    
    return image;
}

-(void)setSpriteInButton:(R2RSprite *)sprite button:(UIButton *)button
{
    [self dequeueSpriteView:sprite:button];
    
    UIImage *image = [self loadImage:sprite.path];
    if (image)
    {
        [button setImage:[sprite getSprite:image] forState:UIControlStateNormal];
        return;
    }

    [self enqueueSpriteView:sprite view:button];
}


-(void)setSpriteInView:(R2RSprite *)sprite view:(UIImageView *)view
{
    [self dequeueSpriteView:sprite:view];
    
    UIImage *image = [self loadImage:sprite.path];
    if (image)
    {
        [view setImage:[sprite getSprite:image]];
        return;
    }
    
    [self enqueueSpriteView:sprite view:view];
}

-(void)imageDidLoad:(R2RImageLoader *)imageLoader
{
    if (imageLoader.image != nil)
    {
        [self.imageStore setObject:imageLoader.image forKey:imageLoader.path];
    
        for (long i = [self.spriteViews count]-1; i >= 0; i--)
        {
            R2RSpriteView *spriteView = [self.spriteViews objectAtIndex:i];
        
            if ([spriteView.sprite.path isEqualToString:imageLoader.path])
            {
                if ([spriteView.view isKindOfClass:[UIButton class]])
                {
                    [spriteView.view setImage:[spriteView.sprite getSprite:imageLoader.image] forState:UIControlStateNormal];
                }
                else
                {
                    [spriteView.view setImage:[spriteView.sprite getSprite:imageLoader.image]];
                }
                [self.spriteViews removeObjectAtIndex:i];
            }
        }
    }

    [self.imageLoaders removeObjectForKey:imageLoader.path];
}

-(void) enqueueSpriteView: (R2RSprite *) sprite view:(id) view
{
    if ([sprite.path length] == 0) return;
    
    R2RSpriteView *spriteView = [[R2RSpriteView alloc] init];
    
    spriteView.sprite = sprite;
    spriteView.view = view;
    
    [self.spriteViews addObject:spriteView];
}

-(void) dequeueSpriteView: (R2RSprite *) sprite : (id) view
{
    for (NSInteger i = [self.spriteViews count]-1; i >= 0; i--)
    {
        R2RSpriteView *candidateSpriteView = [self.spriteViews objectAtIndex:i];
        if (candidateSpriteView.view == view)
        {
            [self.spriteViews removeObjectAtIndex:i];
        }
    }
}
@end
