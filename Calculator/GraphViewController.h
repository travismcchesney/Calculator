//
//  GraphViewController.h
//  Calculator
//
//  Created by Travis McChesney on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *descriptionOfProgram;
@property (nonatomic, strong) NSString *descriptionToGraph;

@end
