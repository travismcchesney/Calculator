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

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize history = _history;
@synthesize description = _description;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize containsDecimal = _containsDecimal;
@synthesize brain = _brain;

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
    self.history.text = [self.history.text stringByAppendingFormat:@"%@ ↵ ", self.display.text];
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *operation = [sender currentTitle];
    double result = [self.brain performOperation:operation];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    self.history.text = [self.history.text stringByAppendingFormat:@"%@ ", sender.currentTitle];
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
    self.history.text = @"";
    self.description.text = @"";
    
    [self.brain clear];
}

- (IBAction)describeProgram:(id)sender 
{
    NSString *description = [[self.brain class] descriptionOfProgram:self.brain.program];
    
    description = [description stringByReplacingCharactersInRange:[description rangeOfString:@"," options:NSBackwardsSearch] withString:@""];
    self.description.text = description;

}

- (void)viewDidUnload {
    [self setHistory:nil];
    [self setDescription:nil];
    [super viewDidUnload];
}
@end
