//
//  GraphViewController.m
//  Calculator
//
//  Created by Travis McChesney on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"

@interface GraphViewController () <GraphViewDataSource>
    @property (nonatomic, weak) IBOutlet GraphView *graphView;
@end

@implementation GraphViewController

@synthesize graphView = _graphView;
@synthesize descriptionOfProgram = _descriptionOfProgram;
@synthesize programToGraph = _programToGraph;

- (NSArray *)programForGraphView:(GraphView *)sender
{
    return self.programToGraph;
}

- (float)resultForVariables:(NSDictionary *)variables
{
    return [[CalculatorBrain class] runProgram:self.programToGraph usingVariableValues:variables];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.descriptionOfProgram.text = [[CalculatorBrain class] descriptionOfProgram:self.programToGraph];
}

- (void)viewDidUnload
{
    [self setDescriptionOfProgram:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    // enable pinch gestures in the FaceView using its pinch: handler
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    //[self.faceView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleHappinessGesture:)]];  // gesture to modify our Model
    self.graphView.dataSource = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
