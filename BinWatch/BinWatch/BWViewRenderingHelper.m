//
//  BWViewRenderingHelper.m
//  BinWatch
//
//  Created by Alpana Negi on 10/7/15.
//  Copyright © 2015 Airwatch. All rights reserved.
//

#import "BWViewRenderingHelper.h"

#define BAR_VIEW_WIDTH 30.0f

@implementation BWViewRenderingHelper

+ (void)addBarGraphOnView:(UIView*)view atOrigin:(CGPoint)origin withFillLevel:(int)fillLevel;
{
    CGRect frame = CGRectMake(origin.x, origin.y - fillLevel, BAR_VIEW_WIDTH, fillLevel);
    UIView *barGraphView = [[UIView alloc]initWithFrame:frame];
    [barGraphView setBackgroundColor:[UIColor brownColor]];
    [view addSubview:barGraphView];
}

@end
