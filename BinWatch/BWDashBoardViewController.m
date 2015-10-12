//
//  BWDashBoardViewController.m
//  BinWatch
//
//  Created by Supritha Nagesha on 10/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWDashBoardViewController.h"
#import "UIColor+HexColor.h"
#import "VBPieChart.h"
#import "BWDataHandler.h"

@interface BWDashBoardViewController ()
@property (nonatomic, retain) VBPieChart *chart;
@property (nonatomic, retain) NSArray *chartValues;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *binsLabel;

@end

@implementation BWDashBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setNeedsLayout];
    [self.locationLabel setText:@"TODO: mention location here"];
    
    if (!_chart) {
        _chart = [[VBPieChart alloc] init];
        [self.view addSubview:_chart];
    }
    [_chart setFrame:CGRectMake(0, 100, 250 , 250)];
    _chart.center = self.view.center;
    [_chart setEnableStrokeColor:YES];
    [_chart setHoleRadiusPrecent:0.3];
    
    [_chart.layer setShadowOffset:CGSizeMake(2, 2)];
    [_chart.layer setShadowRadius:3];
    [_chart.layer setShadowColor:[UIColor blackColor].CGColor];
    [_chart.layer setShadowOpacity:0.7];
    
    
    [_chart setHoleRadiusPrecent:0.3];
    
    [_chart setLabelsPosition:VBLabelsPositionOnChart];
    
    [self setUpChartValues];
    
    [_chart setChartValues:_chartValues animation:YES];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setUpChartValues{
    
    BWDataHandler *dbHandler = [BWDataHandler sharedHandler];
    NSArray * bins = [dbHandler fetchBins];
    NSMutableArray * percentages  = [NSMutableArray array];
    
    if ([bins count]) {
        [self.binsLabel setText:[NSString stringWithFormat:@"Total Bins : %lu",(unsigned long)[bins count]]];
        for(int i = 0 ;i<5 ;i++){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.fill =< %d)",(i+1)*20];
            NSArray *arr = [bins filteredArrayUsingPredicate:predicate];
            long double percent = ((long double)[arr count]/(long double)[bins count]*100);
            [percentages addObject:[NSString stringWithFormat:@"%2.2Lf",percent]];
        }
        self.chartValues = @[
                             @{@"name":@"10%", @"value":[percentages objectAtIndex:0], @"color":[UIColor colorWithHex:0xdd191daa]},
                             @{@"name":@"20%", @"value":[percentages objectAtIndex:1], @"color":[UIColor colorWithHex:0xd81b60aa]},
                             @{@"name":@"30%", @"value":[percentages objectAtIndex:2], @"color":[UIColor colorWithHex:0x8e24aaaa]},
                             @{@"name":@"40%", @"value":[percentages objectAtIndex:3], @"color":[UIColor colorWithHex:0x3f51b5aa]},
                             @{@"name":@"80%", @"value":[percentages objectAtIndex:4], @"color":[UIColor colorWithHex:0xf57c00aa]}
                             ];

    }
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
