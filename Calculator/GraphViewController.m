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
@synthesize graphMethodSwitch = _graphMethodSwitch;
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

- (IBAction)switchGraphMethod:(UISwitch *)sender 
{
    if (sender.on) self.graphView.graphMethod = Line;
    else self.graphView.graphMethod = Pixel;
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
    [self setGraphMethodSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    float originX = [defaults floatForKey:@"GraphViewOriginX"];
    float originY = [defaults floatForKey:@"GraphViewOriginY"];
    float scale = [defaults floatForKey:@"GraphViewScale"];
    
    if (originX && originY)
        self.graphView.origin = CGPointMake(originX, originY);
    if (scale)
        self.graphView.scale = scale;
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setFloat:self.graphView.origin.x forKey:@"GraphViewOriginX"];
    [defaults setFloat:self.graphView.origin.y forKey:@"GraphViewOriginY"];
    [defaults setFloat:self.graphView.scale forKey:@"GraphViewScale"];
    
    [defaults synchronize];
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
    self.graphView.graphMethod = self.graphMethodSwitch.on ? Line : Pixel;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self.graphView resetOrigin];
    return YES;
}

@end
