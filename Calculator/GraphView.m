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

- (float) scale
{
    if (!_scale) _scale = DEFAULT_SCALE;
    return _scale;
}

- (void) setOrigin:(CGPoint)origin
{
    _origin = origin;
    _originIsInitialized = YES;
}

- (void)drawRect:(CGRect)rect
{
    if (!self.originIsInitialized) self.origin = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    
    [[AxesDrawer class] drawAxesInRect:rect originAtPoint:self.origin scale:self.scale];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    float result;
    float x;
    NSDictionary *variables;
    BOOL startPointInitialized = NO;
    
    for (float i = rect.origin.x; i < rect.size.width; ++i)
    {
        x = (i - self.origin.x);
        variables = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:x], @"x", nil]; 
        
        result = [self.dataSource resultForVariables:variables];
        
        result *= -1;
        result += self.origin.y;
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
