//
//  BinDetailsViewController.m
//  BinWatch
//
//  Created by Alpana Negi on 9/30/15.
//  Copyright © 2015 Airwatch. All rights reserved.
//

#import "BinDetailsViewController.h"
#import "BWConstants.h"
#import "BWBinCollection.h"
#import "BWBin.h"
#import "GradientView.h"
#import "BWDataHandler.h"
#import "BWHelpers.h"
#import "BWViewRenderingHelper.h"

#define BAR_VIEW_WIDTH_WITH_SPACING     43.0f
#define CIRCLE_VIEW_TAG_START_VAL       100
#define MAX_GRAPHS_TO_BE_RENDERED       7

@interface BinDetailsViewController ()

@end

@implementation BinDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setUpView];
    [self setUpBarGraphViews];
    [self setUpTemperatureGraph];
    [self joinCirclesWithLine];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBActions

- (IBAction)segmentedControlTapped:(id)sender
{
    NSLog(@"segmented control tapped with index %d", _segmentControl.selectedSegmentIndex);
}

#pragma mark - User Defined Methods

- (void)setUpView
{
    BWBin *currentBin;
    currentBin = [[[BWDataHandler sharedHandler] fetchBins] objectAtIndex:_currentSelectedBinIndex];

    // TODO: hack for iOS9
    if (currentBin == nil)
        currentBin = [[[BWBinCollection sharedInstance] bins]objectAtIndex:_currentSelectedBinIndex];
    //[_binIDView addSubview: [[GradientView alloc]initWithFrame:_binIDView.frame forColor:currentBin.color]];
    [_binLocationLabel setText:[BWHelpers areanameFromFullAddress:currentBin.place]];
    [_binFillPercentLabel setText:[NSString stringWithFormat:@"%ld %%", (long)[currentBin.fill integerValue]]];
}

- (void)setUpBarGraphViews
{
    for (int i = 0; i < MAX_GRAPHS_TO_BE_RENDERED; i++) {
        CGRect barGraphViewFrame = _blackLineImageView.frame;
    
        //todo : dummy fill level. Get fill levels from server 
        float fillLevel = 20 + (arc4random() % 80);
        [BWViewRenderingHelper addBarGraphOnView:_barGraphView atOrigin:CGPointMake(10.0f + (BAR_VIEW_WIDTH_WITH_SPACING * i), barGraphViewFrame.origin.y) withFillLevel:fillLevel];
    }
}

- (void)setUpTemperatureGraph
{
    for (int i = 0; i < MAX_GRAPHS_TO_BE_RENDERED; i++) {
        CGRect barGraphViewFrame = _blackLineImageView.frame;
        
        //todo : dummy temperature details. Get temperature details from server
        [BWViewRenderingHelper addCircleOnView:_barGraphView atOrigin:CGPointMake(17+(BAR_VIEW_WIDTH_WITH_SPACING * i), barGraphViewFrame.origin.y - 20 - arc4random()%85) andTag:CIRCLE_VIEW_TAG_START_VAL+i];
    }
}

- (void)joinCirclesWithLine
{
    for (int i = 0; i < MAX_GRAPHS_TO_BE_RENDERED - 1; i++)
    {
        UIView *circleView1 = [_barGraphView viewWithTag:CIRCLE_VIEW_TAG_START_VAL+i];
        UIView *circleView2 = [_barGraphView viewWithTag:CIRCLE_VIEW_TAG_START_VAL+i+1];
        
        CGPoint circleCenter1 = CGPointMake(circleView1.frame.origin.x + circleView1.frame.size.width * 0.5f, circleView1.frame.origin.y + circleView1.frame.size.height * 0.5f);
        CGPoint circleCenter2 = CGPointMake(circleView2.frame.origin.x + circleView2.frame.size.width * 0.5f, circleView2.frame.origin.y + circleView2.frame.size.height * 0.5f);
        
        [BWViewRenderingHelper joinCircleCenters:circleCenter1 and:circleCenter2 onView:_barGraphView];
    }
}

@end
