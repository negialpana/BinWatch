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

#define BAR_VIEW_WIDTH_WITH_SPACING  43.0f

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
    int maxNoOfGraphs = 7;
    for (int i = 0; i < maxNoOfGraphs; i++) {
        CGRect barGraphViewFrame = _blackLineImageView.frame;
    
        //todo : dummy fill level. Get fill levels from server 
        float fillLevel = 20 + (arc4random() % 80);
        [BWViewRenderingHelper addBarGraphOnView:_barGraphView atOrigin:CGPointMake(10.0f + (BAR_VIEW_WIDTH_WITH_SPACING * i), barGraphViewFrame.origin.y) withFillLevel:fillLevel];
    }
}
@end
