//
//  R2RAnnotation.h
//  Rome2Rio
//
//  Created by Ash Verdoorn on 23/11/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
	r2rAnnotationTypeFrom = 0,
	r2rAnnotationTypeTo,
	r2rAnnotationTypeStop,
    r2rAnnotationTypeHop,
    r2rAnnotationTypePress,
    r2rAnnotationTypeMyLocation,
} R2RAnnotationType;

@interface R2RAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *kind;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) R2RAnnotationType annotationType;

- (id)initWithName:(NSString*)name kind:(NSString*)kind coordinate:(CLLocationCoordinate2D)coordinate annotationType:(R2RAnnotationType) annotationType;

@end
