//
//  R2RAnnotation.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 23/11/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RAnnotation.h"

@implementation R2RAnnotation

@synthesize name = _name;
@synthesize kind = _kind;
@synthesize coordinate = _coordinate;
@synthesize annotationType = _annotationType;


-(id)initWithName:(NSString *)name kind:(NSString *)kind coordinate:(CLLocationCoordinate2D)coordinate annotationType:(R2RAnnotationType)annotationType
{
    if ((self = [super init]))
    {
        _name = [name copy];
        
        //only display items before the ":"
        NSArray *kinds = [kind componentsSeparatedByString:@":"];
        _kind = [kinds objectAtIndex:0];
//        _kind = kind;
        
        _coordinate = coordinate;
        _annotationType = annotationType;
    }
    return self;
}

- (NSString *)title
{
    return _name;
}

- (NSString *)subtitle
{
    return _kind;
}

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}

@end
