//
//  R2RConnection.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 30/08/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RConnection.h"

@interface R2RConnection()

@property (strong, nonatomic) NSURLConnection *connection;

@end    

@implementation R2RConnection

@synthesize responseData, responseStatus, connection, delegate, connectionString, error = _error;

-(id) initWithConnectionUrl:(NSURL *)connectionUrl delegate:(id<R2RConnectionDelegate>)r2rConnectionDelegate
{
    self = [super init];
    
    if (self != nil)
    {
        self.delegate = r2rConnectionDelegate;
        
        self.responseData = [NSMutableData data];
        
        self.responseStatus = 0;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:connectionUrl];
        
        self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

        self.connectionString = [NSString stringWithFormat:@"%@", connectionUrl];
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.responseData setLength:0];
 
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    self.responseStatus = [httpResponse statusCode];
}	

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.error = error;
//    R2RLog(@"%@", error);
    [[self delegate] connectionError:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.responseStatus == 200)
    {
        [[self delegate] connectionProcessData:self];
    }
    else
    {
        [[self delegate] connectionError:self];
    }
}

@end
