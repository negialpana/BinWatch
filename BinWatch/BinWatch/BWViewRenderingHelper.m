//
//  BWViewRenderingHelper.m
//  BinWatch
//
//  Created by Alpana Negi on 10/7/15.
//  Copyright © 2015 Airwatch. All rights reserved.
//

#import "BWViewRenderingHelper.h"

#define BAR_VIEW_WIDTH          30.0f
#define CIRCLE_DIAMETER         16.0f
#define CIRCLE_LINE_WIDTH       6.0f
#define LINE_WIDTH              3.0f
@implementation BWViewRenderingHelper

#pragma mark - Helper Methods

//draw bar graph

+ (void)addBarGraphOnView:(UIView*)view atOrigin:(CGPoint)origin withFillLevel:(int)fillLevel andTag:(int)tag
{
    CGRect frame = CGRectMake(origin.x, origin.y - fillLevel, BAR_VIEW_WIDTH, fillLevel);
    UIView *barGraphView = [[UIView alloc]initWithFrame:frame];
    [barGraphView setBackgroundColor:[UIColor brownColor]];
    [barGraphView setTag:tag];
    [view addSubview:barGraphView];
}

//draw a circle

+ (void)addCircleOnView:(UIView*)view atOrigin:(CGPoint)origin andTag:(int)tag
{
    UIView *circleView = [[UIView alloc]initWithFrame:CGRectMake(origin.x, origin.y, CIRCLE_DIAMETER, CIRCLE_DIAMETER)];
    [circleView setTag:tag];
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:circleView.bounds] CGPath]];
    [circleLayer setLineWidth:CIRCLE_LINE_WIDTH];
    [circleLayer setStrokeColor:[[UIColor blueColor] CGColor]];
    [circleLayer setFillColor:[[UIColor whiteColor] CGColor]];
    [[circleView layer] addSublayer:circleLayer];
    
    [view addSubview:circleView];
}

//draws a line joining two circles

+ (void)joinCircleCenters:(CGPoint)circleCenter1 and:(CGPoint)circleCenter2 onView:(UIView*)view andTag:(int)tag
{
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(circleCenter1.x, circleCenter1.y)];
    [linePath addLineToPoint:CGPointMake(circleCenter2.x, circleCenter2.y)];
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.lineWidth = LINE_WIDTH;
    lineLayer.path = linePath.CGPath;
    lineLayer.strokeColor = [[UIColor yellowColor]CGColor];
    [lineLayer setName:[NSString stringWithFormat:@"%d",tag]];
    
    [[view layer] addSublayer:lineLayer];
}

@end
