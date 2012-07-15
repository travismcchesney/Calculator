//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Travis McChesney on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"

@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL containsDecimal;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues;
@property (nonatomic, strong) NSString *descriptionForGraph;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize description = _description;
@synthesize variables = _variables;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize containsDecimal = _containsDecimal;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;
@synthesize descriptionForGraph = _descriptionForGraph;

// Get the CalculatorBrain instanace.  Lazy instantiation.
- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

// When a digit is pressed, use the current title to determine which digit, and
// update the display with that digit.
- (IBAction)digitPressed:(UIButton *)sender 
{
    NSString *digit = sender.currentTitle;
    // If a number is being entered, append it to the display.
    // Otherwise, set the display to the number.
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

// When enter is pressed, push the operand into the CalculatorBrain.
// The user is no longer entering a number.
// Update the display to reflect the push.
- (IBAction)enterPressed 
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.containsDecimal = NO;
    [self updateDisplay];
}

// When an operation is pressed, simulate an enter press if the user was in
// the middle of entering a number.
// Request the CalculatorBrain to perform the operation, and then update
// the display.
- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *operation = [sender currentTitle];
    [self.brain performOperation:operation];
    [self updateDisplay];
}

// When a decimal is pressed, determine if there is already a decimal in the 
// number, and if it's the first digit in the display.  Set or append accordingly.
- (IBAction)decimalPressed:(id)sender 
{
    if (!self.userIsInTheMiddleOfEnteringANumber)
        self.display.text = @"0.";
    else if (!self.containsDecimal)
        self.display.text = [self.display.text stringByAppendingString:@"."];
    
    self.userIsInTheMiddleOfEnteringANumber = YES;
    self.containsDecimal = YES;
}

// When clear is pressed, clear the display, description, and CalculatorBrain.
- (IBAction)clear:(id)sender 
{
    self.display.text = @"0";
    self.description.text = @"";
    
    [self.brain clear];
}

- (IBAction)graph:(id)sender 
{
    self.descriptionForGraph = [[self.brain class] descriptionOfProgram:self.brain.program];
    [self performSegueWithIdentifier:@"ShowGraph" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowGraph"]) {
        [segue.destinationViewController setDescriptionToGraph:self.descriptionForGraph];
    }
}

// Describe the program using the CalculatorBrain's description API.
- (void)describeProgram
{
    NSString *description = [[self.brain class] descriptionOfProgram:self.brain.program];
    self.description.text = description;
}

// Update the display text by running the program in the CalculatorBrain.
// Update the variables display by evaluating which variables are defined.
- (void)updateDisplay
{
    self.display.text = [NSString stringWithFormat:@"%g", [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues]];
    [self describeProgram];
}

// Remove the last character in the display, or the last item on the stack if the display is empty.
- (IBAction)undo:(id)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber)
        self.display.text = [self.display.text substringToIndex:[self.display.text length] - 1];
    else {
        [self.brain popFromStack];
        [self updateDisplay];
    }
    
    if (self.display.text.length == 0) {
        self.userIsInTheMiddleOfEnteringANumber = NO;
        [self updateDisplay];
    }

}

- (void)viewDidUnload {
    [self setDescription:nil];
    [self setVariables:nil];
    [super viewDidUnload];
}
@end
