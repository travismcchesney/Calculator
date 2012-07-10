//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Travis McChesney on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL containsDecimal;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize description = _description;
@synthesize variables = _variables;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize containsDecimal = _containsDecimal;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender 
{
    NSString *digit = sender.currentTitle;
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)enterPressed 
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.containsDecimal = NO;
    [self updateDisplay];
    //self.history.text = [self.history.text stringByAppendingFormat:@"%@ ↵ ", self.display.text];
    //[self describeProgram:nil];
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *operation = [sender currentTitle];
    double result = [self.brain performOperation:operation];
    [self updateDisplay];
    //self.display.text = [NSString stringWithFormat:@"%g", result];
    //self.history.text = [self.history.text stringByAppendingFormat:@"%@ ", sender.currentTitle];
    //[self describeProgram:nil];
}

- (IBAction)decimalPressed:(id)sender 
{
    if (!self.userIsInTheMiddleOfEnteringANumber)
        self.display.text = @"0.";
    else if (!self.containsDecimal)
        self.display.text = [self.display.text stringByAppendingString:@"."];
    
    self.userIsInTheMiddleOfEnteringANumber = YES;
    self.containsDecimal = YES;
}

- (IBAction)clear:(id)sender 
{
    self.display.text = @"0";
    //self.history.text = @"";
    self.description.text = @"";
    
    [self.brain clear];
}

- (void)describeProgram:(id)sender 
{
    NSString *description = [[self.brain class] descriptionOfProgram:self.brain.program];
    
    description = [description stringByReplacingCharactersInRange:[description rangeOfString:@"," options:NSBackwardsSearch] withString:@""];
    self.description.text = description;

}

- (void)updateDisplay
{
    self.display.text = [NSString stringWithFormat:@"%g", [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues]];
    [self describeProgram:nil];
    NSSet *variableSet = [CalculatorBrain variablesUsedInProgram:self.brain.program];
    self.variables.text = @"";
    for (NSString *var in variableSet) {
        self.variables.text = [self.variables.text stringByAppendingString:[NSString stringWithFormat:@"%@ = %@ ", var, [[self testVariableValues] valueForKey:var]]];
    }
}

- (IBAction)test1:(id)sender
{
    self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:5], @"x", [NSNumber numberWithDouble:10], @"y", [NSNumber numberWithDouble:20], @"z", nil];
    [self updateDisplay];
}

- (IBAction)test2:(id)sender 
{
    self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:1], @"x", [NSNumber numberWithDouble:2], @"y", [NSNumber numberWithDouble:3], @"z", nil];
    [self updateDisplay];
}

- (IBAction)test3:(id)sender 
{
    self.testVariableValues = nil;
    [self updateDisplay];
}

- (void)viewDidUnload {
    //[self setHistory:nil];
    [self setDescription:nil];
    [self setVariables:nil];
    [super viewDidUnload];
}
@end
