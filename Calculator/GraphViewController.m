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
#import "SplitViewBarButtonItemPresenter.h"

@interface GraphViewController () <GraphViewDataSource, SplitViewBarButtonItemPresenter>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@property (nonatomic,weak) IBOutlet UIToolbar *toolbar;
@end

@implementation GraphViewController

@synthesize graphView = _graphView;
@synthesize descriptionOfProgram = _descriptionOfProgram;
@synthesize programToGraph = _programToGraph;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolbar = _toolbar;

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (NSArray *)programForGraphView:(GraphView *)sender
{
    return self.programToGraph;
}

- (void)setProgramToGraph:(NSArray *)programToGraph
{
    _programToGraph = programToGraph;
    [self.graphView setNeedsDisplay];
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
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    
    UITapGestureRecognizer *tripleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tripleTap:)];
    tripleTapRecognizer.numberOfTapsRequired = 3;
    
    [self.graphView addGestureRecognizer:tripleTapRecognizer];
    self.graphView.dataSource = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self.graphView resetOrigin];
    return YES;
}

@end
