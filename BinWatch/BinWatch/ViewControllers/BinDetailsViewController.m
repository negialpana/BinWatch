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
#import "BWConnectionHandler.h"

#define BAR_VIEW_WIDTH_WITH_SPACING     43.0f
#define CIRCLE_VIEW_TAG_START_VAL       100
#define MAX_GRAPHS_TO_BE_RENDERED       7

@interface BinDetailsViewController ()

@property (nonatomic, retain) BWBin *currentBin;
@property (nonatomic, retain) NSArray *currentBinHumidityData;
@property (nonatomic, retain) NSArray *currentBinTemperatureData;

@end

@implementation BinDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initVars];
    [self setUpView];
    [self getCurrentBinData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (void)initVars
{
    _currentBinHumidityData = nil;
    _currentBinTemperatureData = nil;
}

- (void)setUpView
{
    self.currentBin = [[[BWDataHandler sharedHandler] fetchBins] objectAtIndex:_currentSelectedBinIndex];

    // TODO: hack for iOS9
    if (self.currentBin == nil)
        self.currentBin = [[[BWBinCollection sharedInstance] bins]objectAtIndex:_currentSelectedBinIndex];
    //[_binIDView addSubview: [[GradientView alloc]initWithFrame:_binIDView.frame forColor:currentBin.color]];
    if([self.currentBin.fill integerValue] > RED_BOUNDARY)
        _binIDView.backgroundColor = RedColor;
    else if ([self.currentBin.fill integerValue] > YELLOW_BOUNDARY)
        _binIDView.backgroundColor = YellowColor;
    else
        _binIDView.backgroundColor = GreenColor;
    
    [_binLocationLabel setText:[BWHelpers areanameFromFullAddress:self.currentBin.place]];
    [_binFillPercentLabel setText:[NSString stringWithFormat:@"%ld %%", (long)[self.currentBin.fill integerValue]]];
}

- (void)getCurrentBinData
{
    NSDate *today = [NSDate date];
    NSDate *sevenDaysAgo = [today dateByAddingTimeInterval:- 7*24*60*60];
    
    //get temperature data
    [[BWConnectionHandler sharedInstance] getBinData:self.currentBin.binID from:sevenDaysAgo to:today forParam:BWTemperature
                               WithCompletionHandler:^(NSArray *binData, NSError *error) {
                                   
                                   if (!error) {
                                        _currentBinTemperatureData = binData;
                                       
                                       //get humidity data after temperature data is fetched
                                       [[BWConnectionHandler sharedInstance] getBinData:self.currentBin.binID from:sevenDaysAgo to:today forParam:BWHumidity
                                                                  WithCompletionHandler:^(NSArray *binData, NSError *error) {
                                                                      
                                                                      if (!error) {
                                                                          _currentBinHumidityData = binData;
                                                                          [self plotGraphs];
                                                                      } else
                                                                      {
                                                                          NSLog(@"%@", [error localizedDescription]);
                                                                      }
                                                                  }];
                                   } else
                                   {
                                       NSLog(@"%@", [error localizedDescription]);
                                   }
                               }];
}

- (void)plotGraphs
{
    [self setUpBarGraphViews];
    [self setUpTemperatureGraph];
    [self joinCirclesWithLine];
}

- (void)setUpBarGraphViews
{
    float offsetX = 10.0f;
    for (int i = 0; i < [_currentBinHumidityData count]; i++) {
        CGRect barGraphViewFrame = _blackLineImageView.frame;
        
        int humidityLevel = [[[_currentBinHumidityData objectAtIndex:i]objectForKey:@"humidity"]intValue];
        
        [BWViewRenderingHelper addBarGraphOnView:_barGraphView atOrigin:CGPointMake(offsetX + (BAR_VIEW_WIDTH_WITH_SPACING * i), barGraphViewFrame.origin.y) withFillLevel:humidityLevel];
    }
}

- (void)setUpTemperatureGraph
{
    float offsetY = 20.0f;
    float offsetX = 17.0f;
    
    for (int i = 0; i < [_currentBinTemperatureData count]; i++) {
        CGRect barGraphViewFrame = _blackLineImageView.frame;
        
        int temperature = [[[_currentBinTemperatureData objectAtIndex:i]objectForKey:@"temperature"]intValue];
        
        [BWViewRenderingHelper addCircleOnView:_barGraphView atOrigin:CGPointMake(offsetX + (BAR_VIEW_WIDTH_WITH_SPACING * i), barGraphViewFrame.origin.y - offsetY - temperature) andTag:CIRCLE_VIEW_TAG_START_VAL+i];
    }
}

- (void)joinCirclesWithLine
{
    for (int i = 0; i < [_currentBinTemperatureData count] - 1; i++)
    {
        UIView *circleView1 = [_barGraphView viewWithTag:CIRCLE_VIEW_TAG_START_VAL+i];
        UIView *circleView2 = [_barGraphView viewWithTag:CIRCLE_VIEW_TAG_START_VAL+i+1];
        
        CGPoint circleCenter1 = CGPointMake(circleView1.frame.origin.x + circleView1.frame.size.width * 0.5f, circleView1.frame.origin.y + circleView1.frame.size.height * 0.5f);
        CGPoint circleCenter2 = CGPointMake(circleView2.frame.origin.x + circleView2.frame.size.width * 0.5f, circleView2.frame.origin.y + circleView2.frame.size.height * 0.5f);
        
        [BWViewRenderingHelper joinCircleCenters:circleCenter1 and:circleCenter2 onView:_barGraphView];
    }
}

@end
