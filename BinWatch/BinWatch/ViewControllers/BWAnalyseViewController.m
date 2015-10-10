//
//  BWAnalyseViewController.m
//  BinWatch
//
//  Created by Supritha Nagesha on 10/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWAnalyseViewController.h"

@interface BWAnalyseViewController ()

@property (weak, nonatomic) IBOutlet UILabel *queryLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateRangeLabel;

@end

@implementation BWAnalyseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    [_dateRangeLabel setText:[NSString stringWithFormat:@"%@ - %@",[formatter stringFromDate:_fromDate],[formatter stringFromDate:_toDate]]];
    [_queryLabel setText:_query];
    // Do any additional setup after loading the view.
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

@end
