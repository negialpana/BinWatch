//
//  GraphView.m
//  BinWatch
//
//  Created by Supritha Nagesha on 29/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

    
    NSLog(@"%@", [_binsArray description]);
    
    
    
    [self evaluateYAxisValues];
    
//    for(NSDictionary *dict in _binsArray){
//        NSArray *dataArray = [dict valueForKey:@"DataArray"];
//        UIBezierPath *aPath1 = [UIBezierPath bezierPath];
//        [aPath1 moveToPoint:CGPointMake(0.0, 0.0)];
//        [aPath1 setLineWidth:2.0];
//        for(id obj in dataArray){
//            
//           // [aPath1 addLineToPoint:CGPointMake([obj valueForKey:@"fill"], 0)];
//        }
//        
//    }
   
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    
    // Set the starting point of the shape.
    [aPath moveToPoint:CGPointMake(100.0, 0.0)];
    [aPath setLineWidth:2.0];
    
    // Draw the lines.
    [aPath addLineToPoint:CGPointMake(200.0, 40.0)];
    [aPath addLineToPoint:CGPointMake(160, 140)];
    [aPath addLineToPoint:CGPointMake(40.0, 140)];
    [aPath addLineToPoint:CGPointMake(0.0, 40.0)];
    [aPath closePath];
    [aPath stroke];
}

- (void)evaluateYAxisValues{
    
    NSMutableSet *set = [NSMutableSet set];
    for(NSDictionary *dic in _binsArray){
        
        NSArray *dataA = [dic valueForKey:@"DataArray"];
        NSString * str = [[dataA valueForKeyPath:@"timestamp"] componentsJoinedByString:@","];
        [set addObjectsFromArray:[str componentsSeparatedByString:@","]];
    }
    NSLog(@"%@",[set description]);
}

@end
