//
//  BinDetailsViewController.h
//  BinWatch
//
//  Created by Alpana Negi on 9/30/15.
//  Copyright © 2015 Airwatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BinDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *weekView;
@property (weak, nonatomic) IBOutlet UIView *customDateView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIView *binVariablesView;
@property (weak, nonatomic) IBOutlet UIView *barGraphView;
@property (weak, nonatomic) IBOutlet UILabel *binLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *binFillPercentLabel;
@property (strong, nonatomic) IBOutlet UIView *binIDView;
@property (weak, nonatomic) IBOutlet UIImageView *blackLineImageView;
@property (weak, nonatomic) IBOutlet UILabel *nextFillDate;

@property (assign) int currentSelectedBinIndex;

- (IBAction)segmentedControlTapped:(id)sender;
- (IBAction)dateSelectButtonPressed:(id)sender;

@end
