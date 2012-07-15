//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Travis McChesney on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

@property (nonatomic, strong) NSMutableArray *programStack;

@end

static NSSet *operations = nil;

@implementation CalculatorBrain

@synthesize programStack = _programStack;

// Get the set of all defined operations.
+ (NSSet *)operations
{
    if (!operations) operations = [[NSSet alloc] initWithObjects:@"+",@"*",@"-",@"/",@"sin",@"cos",@"√",@"π", nil];
    return operations;
}

// Get the program stack.
- (NSMutableArray *)programStack
{
    // lazily instantiate
    if (_programStack == nil) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

// we must return some object (of any class) that represents
//  all the operands and operations performed on this instance
//  so that it can be played back via runProgram:
// we'll simply return an immutable copy of our internal data structure

- (id)program
{
    return [self.programStack copy];
}

// just pushes the operand onto our stack internal data structure.
- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

// Push a variable operand onto our stack.
- (void)pushVariableOperand:(NSString *)variable
{
    if (![variable isEqualToString:@"sin"] &&
        ![variable isEqualToString:@"cos"])
        [self.programStack addObject:variable];
}

// Pop the top item off of the program stack.
- (id)popFromStack
{
    id topOfStack = [self.programStack lastObject];
    if (topOfStack) [self.programStack removeLastObject];
    
    return topOfStack;
}

// Add the operation to the program stack.
- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [[CalculatorBrain class] runProgram:[self program]];
}

// Clear the program stack.
- (void)clear
{
    [self.programStack removeAllObjects];
}

// if the top thing on the passed stack is an operand, return it
// if the top thing on the passed stack is an operation, evaluate it (recursively)
// does not crash (but returns 0) if stack contains objects other than NSNumber or NSString
+ (double)popOperandOffProgramStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffProgramStack:stack] +
            [self popOperandOffProgramStack:stack];
        } else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffProgramStack:stack] *
            [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffProgramStack:stack];
            result = [self popOperandOffProgramStack:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            if (divisor) result = [self popOperandOffProgramStack:stack] / divisor;
        } else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperandOffProgramStack:stack]);;
        } else if ([operation isEqualToString:@"√"]) {
            result = sqrt([self popOperandOffProgramStack:stack]);;
        } else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        }
    }
    
    return result;
}

// checks to be sure passed program is actually an array
//  then evaluates it by calling popOperandOffProgramStack:
// assumes popOperandOffProgramStack: protects against junk array contents

+ (double)runProgram:(id)program
{
    return [self runProgram:program usingVariableValues:nil];
}

// Run the specified program with the supplied dictionary of variables.
// Replace the variables in the program stack with the values from the dictionary.
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];

        id element;
        for (int i = 0; i < stack.count; ++i) {
            element = [program objectAtIndex:i];
            
            if ([element isKindOfClass:[NSString class]] &&
                ![self isOperation:element]) {
                [stack replaceObjectAtIndex:i withObject:([variableValues objectForKey:element]) ? [variableValues objectForKey:element] : [NSNumber numberWithDouble:0]];
            }
        }
    }

    return [self popOperandOffProgramStack:stack];
}

// Return a set with all of the variables used in the specified program.
+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableArray *variablesUsed = [[NSMutableArray alloc] init];
    
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        
        id element;
        for (int i = 0; i < stack.count; ++i) {
            element = [program objectAtIndex:i];
            
            if ([element isKindOfClass:[NSString class]] &&
                ![operations containsObject:element]) {
                [variablesUsed addObject:[program objectAtIndex:i]];
            }
        }
    }
    
    if (variablesUsed.count > 0)
        return [NSSet setWithArray:variablesUsed];
    else
        return nil;
}

// Describe the program stack (ex: (1+2)*4).
+ (NSString *)descriptionOfProgram:(id)program
{
    NSString *description = [self describeProgram:program];
    return (description.length > 0) ? [description stringByReplacingCharactersInRange:[description rangeOfString:@"," options:NSBackwardsSearch] withString:@""] : @"";
}

// Recursively describe each of the operation segments in the program stack.
+ (NSString *)describeProgram:(id)program
{
    NSMutableArray *stack;
    NSString *description;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    if (!stack || [stack count] == 0) return @"";
    
    description = [NSString stringWithFormat:@"%@, ", [self describeOperand:stack]];
    
    return [description stringByAppendingString:[self describeProgram:stack]];
}

// Recursively describe each of the operands in the specified stack.
// Determine the operation precedence of the left and right operands to ensure
// the parentheses are placed correctly.
+ (NSString *)describeOperand:(NSMutableArray *)stack
{
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        return [NSString stringWithFormat:@"%@", topOfStack];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            id op2 = [self describeOperand:stack];
            id op1 = [self describeOperand:stack];
            return [NSString stringWithFormat:@"%@ + %@", op1, op2];
        } else if ([@"*" isEqualToString:operation]) {
            int op2Precedence = [self getNextPrecedence:stack];
            id op2 = [self describeOperand:stack];
            int op1Precedence = [self getNextPrecedence:stack];
            id op1 = [self describeOperand:stack];
            if (op2Precedence > 1)
                return [NSString stringWithFormat:@"%@ * (%@)", op1, op2];
            else if (op1Precedence > 1)
                return [NSString stringWithFormat:@"(%@) * %@", op1, op2];
            else
                return [NSString stringWithFormat:@"%@ * %@", op1, op2];
        } else if ([operation isEqualToString:@"-"]) {
            NSString *subtrahend = [self describeOperand:stack];
            NSString *op1 = [self describeOperand:stack];
            return [NSString stringWithFormat:@"%@ - %@", op1, subtrahend];
        } else if ([operation isEqualToString:@"/"]) {
            int divisorPrecedence = [self getNextPrecedence:stack];
            NSString *divisor = [self describeOperand:stack];
            int op1Precedence = [self getNextPrecedence:stack];
            id op1 = [self describeOperand:stack];
            if (divisor) {
                if (divisorPrecedence > 1)
                    return [NSString stringWithFormat:@"%@ / (%@)", op1, divisor];
                else if (op1Precedence > 1)
                    return [NSString stringWithFormat:@"(%@) / %@", op1, divisor];
                else
                    return [NSString stringWithFormat:@"%@ / %@", op1, divisor];
            }
        } else if ([operation isEqualToString:@"sin"]) {
            return [NSString stringWithFormat:@"sin(%@)", [self describeOperand:stack]];
        } else if ([operation isEqualToString:@"cos"]) {
            return [NSString stringWithFormat:@"cos(%@)", [self describeOperand:stack]];
        } else if ([operation isEqualToString:@"√"]) {
            return [NSString stringWithFormat:@"√(%@)", [self describeOperand:stack]];
        } else if ([operation isEqualToString:@"π"]) {
            return @"π";
        } else {
            return [NSString stringWithFormat:@"%@", topOfStack];
        }
    }
    
    return @"0";
}

// Determine if an element is an opertion (/, *, +, -) or not.
+ (BOOL)isOperation:(id)element
{
    return [[self operations] containsObject:element];
}

// Get the precedence of the next operand on the stack.
+ (int)getNextPrecedence:(NSArray *)stack
{
    id topOfStack = [stack lastObject];
    
    if ([topOfStack isKindOfClass:[NSString class]]) {
        if ([topOfStack isEqualToString:@"/"] ||
            [topOfStack isEqualToString:@"*"])
            return 1;
        if ([topOfStack isEqualToString:@"+"] ||
            [topOfStack isEqualToString:@"-"])
            return 2;
    }
    return 0;
}

@end
