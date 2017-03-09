//
//  R2RImageLoader.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 15/10/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RImageLoader.h"
#import "R2RConnection.h"

@interface R2RImageLoader() <R2RConnectionDelegate>

@property (strong, nonatomic) R2RConnection *connection;

@end

@implementation R2RImageLoader

@synthesize delegate, path = _path;

-(id)initWithPath:(NSString *)path
{
    self = [super init];
    
    if (self != nil)
    {
        self.path = path;
    }
    
    return self;
}

-(void)sendAsynchronousRequest
{
    
#if DEBUG
    NSString *imageString = [NSString stringWithFormat:@"https://working.rome2rio.com%@", self.path];
#else
    NSString *imageString = [NSString stringWithFormat:@"https://ios.rome2rio.com%@", self.path];
#endif
    
    NSString *imageEncoded = [imageString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *imageUrl =  [NSURL URLWithString:imageEncoded];
    
    self.connection = [[R2RConnection alloc] initWithConnectionUrl:imageUrl delegate:self];
}

-(void)connectionProcessData:(R2RConnection *)connection
{
    if (self.connection == connection)
    {
        self.image = [[UIImage alloc] initWithData:self.connection.responseData];
        
        [self.delegate imageDidLoad:self];
    }
}

-(void)connectionError:(R2RConnection *)connection
{
    R2RLog(@"Connection Error");
}

@end
