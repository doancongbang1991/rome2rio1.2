//
//  R2RPressAnnotationView.m
//  Rome2Rio
//
//  Created by Ash Verdoorn on 23/11/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "R2RPressAnnotationView.h"
#import "R2RConstants.h"

@interface R2RPressAnnotationView()

@property (nonatomic) CGSize contentSize;
@property (nonatomic) CGSize sizeOfCalloutTriangle;
@property (nonatomic) float offsetAboveParent;

@end

@implementation R2RPressAnnotationView

@synthesize fromButton, toButton;

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        self.contentSize = CGSizeMake(120.0, 75.0);
        self.sizeOfCalloutTriangle = CGSizeMake(15.0, 15.0);
        self.offsetAboveParent = 0.0;
        
        CGRect frame = self.frame;
        frame.size = CGSizeMake(self.contentSize.width, self.contentSize.height + self.sizeOfCalloutTriangle.height + self.offsetAboveParent);
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        
        self.centerOffset = CGPointMake(0.0, self.offsetAboveParent - (self.frame.size.height/2));
        
        self.fromButton = [R2RSearchButton buttonWithType:UIButtonTypeRoundedRect];
        [self.fromButton setFrame:CGRectMake(5, 5, 110, 30)];
        [self.fromButton setTitle:@"From here" forState:UIControlStateNormal];
        [self.fromButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        [self.fromButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.fromButton.tintColor = [R2RConstants getButtonHighlightColor];
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0)
        {
            [self.fromButton setTitleColor:[R2RConstants getButtonHighlightColor] forState:UIControlStateNormal];
        }
        [self addSubview:self.fromButton];
        
        self.toButton = [R2RSearchButton buttonWithType:UIButtonTypeRoundedRect];
        [self.toButton setFrame:CGRectMake(5, 40, 110, 30)];
        [self.toButton setTitle:@"To here" forState:UIControlStateNormal];
        [self.toButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        [self.toButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.toButton.tintColor = [R2RConstants getButtonHighlightColor];
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0)
        {
            [self.toButton setTitleColor:[R2RConstants getButtonHighlightColor] forState:UIControlStateNormal];
        }
        [self addSubview:self.toButton];
  
    }
    return self;
}

//- (void)setAnnotation:(id <MKAnnotation>)annotation
//{
//    [super setAnnotation:annotation];
//}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    
    CGFloat stroke = 1.0;
	CGFloat radius = 5.0;
    
    rect = self.bounds;
	rect.size.width -= stroke;
	rect.size.height -= stroke + self.sizeOfCalloutTriangle.height + self.offsetAboveParent;
	rect.origin.x += stroke / 2.0;
	rect.origin.y += stroke / 2.0;

    // draw the callout bubble:
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, rect.origin.x + radius, rect.origin.y);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y);
    CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + radius , radius, -M_PI / 2, 0.0, 0);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - radius);
    CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius , radius, 0, M_PI / 2, 0);

    CGPathAddLineToPoint(path, NULL, rect.origin.x + (rect.size.width/2) + (self.sizeOfCalloutTriangle.width/2), rect.origin.y + rect.size.height);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + (rect.size.width/2), rect.origin.y + rect.size.height + self.sizeOfCalloutTriangle.height);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + (rect.size.width/2) - (self.sizeOfCalloutTriangle.width/2), rect.origin.y + rect.size.height);

    CGPathAddLineToPoint(path, NULL, rect.origin.x + radius, rect.origin.y + rect.size.height);
    CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + rect.size.height - radius , radius, M_PI / 2, M_PI, 0);
    CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y + radius);
    CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + radius , radius, M_PI , -M_PI / 2, 0);

    CGPathCloseSubpath(path);
    
    CGContextAddPath(context, path);
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0 alpha:0.6].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.2 alpha:0.9].CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0, 5.0), 5.0, [UIColor colorWithWhite:0 alpha:0.5].CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);

    CGContextRestoreGState(context);

    CGPathRelease(path);
}

@end
