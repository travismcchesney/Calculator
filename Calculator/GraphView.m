//
//  GraphView.m
//  Calculator
//
//  Created by Travis McChesney on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@interface GraphView ()
@property (nonatomic) CGPoint origin;
@property (nonatomic) float scale;
@property (nonatomic) BOOL originIsInitialized;
@end

@implementation GraphView


#define DEFAULT_SCALE 1.0

@synthesize dataSource = _dataSource;
@synthesize origin = _origin;
@synthesize scale = _scale;
@synthesize originIsInitialized = _originIsInitialized;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (float)scale
{
    if (!_scale) _scale = DEFAULT_SCALE;
    return _scale;
}

- (void)setScale:(float)scale
{
    if (scale != _scale) {
        _scale = scale;
        [self setNeedsDisplay];
    }
    
}

- (void)setOrigin:(CGPoint)origin
{
    _origin = origin;
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale; // adjust our scale
        gesture.scale = 1;           // reset gestures scale to 1 (so future changes are incremental, not cumulative)
    }
}

- (void)drawRect:(CGRect)rect
{    
    if (!self.originIsInitialized) self.origin = CGPointMake(rect.size.width / 2, rect.size.height / 2); //CGPointMake(scaledWidth / 2, scaledHeight / 2);
    
    
    [[AxesDrawer class] drawAxesInRect:rect originAtPoint:self.origin scale:self.scale];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    float result;
    float x;
    NSDictionary *variables;
    BOOL startPointInitialized = NO;
    
    for (float i = rect.origin.x; i < rect.size.width; ++i)
    {
        // Translate x into translated and scaled value 
        x = (i - self.origin.x) / self.scale;
        
        // Set the value of x into the variables dictionary
        variables = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:x], @"x", nil]; 
        
        // Calculate the result of the datasource calculation using the variables dictionary
        result = [self.dataSource resultForVariables:variables];
        
        // Translate the result into actual pixels
        result *= -1 * self.scale;
        result += self.origin.y;
        
        // Translate x back to actual pixels
        x *= self.scale;
        x += self.origin.x;

        
        if (!startPointInitialized){
            CGContextMoveToPoint(context, x, result);
            startPointInitialized = YES;
        }
        CGContextAddLineToPoint(context, x, result);
        
        //CGContextFillRect(context, CGRectMake(x,result,1,1));
    }
    
    CGContextStrokePath(context);
}

@end
