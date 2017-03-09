//
//  R2RImageLoader.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 15/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol R2RImageLoaderDelegate;

@interface R2RImageLoader : NSObject

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *path;
@property (weak, nonatomic) id<R2RImageLoaderDelegate> delegate;

-(id) initWithPath:(NSString *) path;
-(void) sendAsynchronousRequest;

@end

@protocol R2RImageLoaderDelegate <NSObject>

- (void)imageDidLoad:(R2RImageLoader *) imageLoader;

@end