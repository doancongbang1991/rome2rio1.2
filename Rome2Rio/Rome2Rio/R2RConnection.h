//
//  R2RConnection.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 30/08/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol R2RConnectionDelegate;


@interface R2RConnection : NSObject

@property (weak, nonatomic) id<R2RConnectionDelegate> delegate;
@property (strong, nonatomic) NSMutableData *responseData;
@property (nonatomic) NSInteger responseStatus;
@property (strong, nonatomic) NSString *connectionString;
@property (strong, nonatomic) NSError *error;

-(id) initWithConnectionUrl:(NSURL *)connectionUrl delegate:(id<R2RConnectionDelegate>)r2rConnectionDelegate;

@end


@protocol R2RConnectionDelegate <NSObject>

- (void) connectionProcessData:(R2RConnection *)connection;
- (void) connectionError:(R2RConnection *)connection;

@end

