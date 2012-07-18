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


#define DEFAULT_SCALE 10.0

@synthesize dataSource = _dataSource;
@synthesize origin = _origin;
@synthesize scale = _scale;
@synthesize originIsInitialized = _originIsInitialized;

- (void)setup
{
    self.contentMode = UIViewContentModeRedraw; // if our bounds changes, redraw ourselves
}

- (void)awakeFromNib
{
    [self setup]; // get initialized when we come out of a storyboard
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
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

- (void)resetOrigin
{
    self.originIsInitialized = NO;
}

- (CGPoint)origin
{
    if (!self.originIsInitialized)
    {
        _origin = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        self.originIsInitialized = YES;
    }
    
    return _origin;
}

- (void)setOrigin:(CGPoint)origin
{
    _origin = origin;
    [self setNeedsDisplay];
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale; // adjust our scale
        gesture.scale = 1;           // reset gestures scale to 1 (so future changes are incremental, not cumulative)
    }
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [gesture translationInView:self];
        self.origin = CGPointMake(self.origin.x + translation.x, self.origin.y + translation.y);
        
        [gesture setTranslation:CGPointZero inView:self];
    }
}

- (void)tripleTap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        self.origin = [gesture locationInView:self];
    }
}

- (void)drawRect:(CGRect)rect
{    
    [[AxesDrawer class] drawAxesInRect:rect originAtPoint:self.origin scale:self.scale];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    float result;
    float x;
    NSDictionary *variables;
    BOOL startPointInitialized = NO;

    for (float i = rect.origin.x; i < rect.size.width; i += 1 / self.contentScaleFactor)
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
