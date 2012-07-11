//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Travis McChesney on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (void)pushVariableOperand:(NSString *)variable;
- (id)popFromStack;
- (double)performOperation:(NSString *)operation;
- (void)clear;

// returns an object of unspecified class which
// represents the sequence of operands and operations
// since last clear
@property (nonatomic, readonly) id program;

// a string representing (to an end user) the passed program
// (programs are obtained from the program @property of a CalculatorBrain instance)
+ (NSString *)descriptionOfProgram:(id)program;

// runs the program (obtained from the program @property of a CalculatorBrain instance)
// if the last thing done in the program was pushOperand:, this returns that operand
// if the last thing done in the program was performOperation:, this evaluates it (recursively)
+ (double)runProgram:(id)program;

+ (double)runProgram:(id)program 
 usingVariableValues:(NSDictionary *)variableValues;

+ (NSSet *)variablesUsedInProgram:(id)program;

@end
