//
//  GraphView.h
//  Calculator
//
//  Created by Travis McChesney on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDataSource
- (float)resultForVariables:(NSDictionary *)variables;
@end

@interface GraphView : UIView

- (void)resetOrigin;

@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;

@end
