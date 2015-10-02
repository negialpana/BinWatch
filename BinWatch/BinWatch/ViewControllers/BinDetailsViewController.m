//
//  BinDetailsViewController.m
//  BinWatch
//
//  Created by Alpana Negi on 9/30/15.
//  Copyright © 2015 Airwatch. All rights reserved.
//

#import "BinDetailsViewController.h"
#import "BWCommon.h"
#import "BWBinCollection.h"
#import "BWBin.h"
#import "GradientView.h"

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
    BWBin *currentBin = [[[BWBinCollection sharedInstance] bins]objectAtIndex:_currentSelectedBinIndex];
    
    //[_binIDView addSubview: [[GradientView alloc]initWithFrame:_binIDView.frame forColor:currentBin.color]];
    [_binLocationLabel setText:currentBin.place];
    [_binFillPercentLabel setText:[NSString stringWithFormat:@"%d %%", (int)currentBin.fillPercent]];
}

@end
