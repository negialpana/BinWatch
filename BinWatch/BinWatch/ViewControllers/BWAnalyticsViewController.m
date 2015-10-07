//
//  BWAnalyticsViewController.m
//  BinWatch
//
//  Created by Supritha Nagesha on 03/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWAnalyticsViewController.h"
#import "QueryParameterCell.h"

static NSString *queryParameterCell = @"queryParameterCell";

@interface BWAnalyticsViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView2;
@property (nonatomic, strong) NSArray *table2Data;
@property (weak, nonatomic) IBOutlet UIButton *fromDateBtn;
@property (weak, nonatomic) IBOutlet UIButton *toDateBtn;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIDatePicker *toDatePicker;
@property (weak, nonatomic) IBOutlet UIView *dateComponentsContainerView;
- (IBAction)fromDateBtnPressed:(id)sender;
- (IBAction)toDateBtnPressed:(id)sender;

@end

@implementation BWAnalyticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [_fromDateBtn setTitle:[[self dateFormatter] stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    [_toDateBtn setTitle:[[self dateFormatter] stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    
    self.table2Data = [NSArray arrayWithObjects:@"", nil];
    // Do any additional setup after loading the view.
}

- (NSDateFormatter *)dateFormatter{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    return formatter;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView2) {
        return 3;
    }else{
        return 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QueryParameterCell *cell = [tableView dequeueReusableCellWithIdentifier:queryParameterCell];
    return cell;
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

- (IBAction)fromDateBtnPressed:(id)sender {
    
    self.dateComponentsContainerView.hidden = YES;
    _datePicker = [[UIDatePicker alloc] initWithFrame:_dateComponentsContainerView.frame];
        [_datePicker addTarget:self action:@selector(fromDatePickerDidSelectTheDate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_datePicker];
    
}

- (void)fromDatePickerDidSelectTheDate:(UIDatePicker *)picker{
    [_fromDateBtn setTitle:[[self dateFormatter] stringFromDate:[picker date]] forState:UIControlStateNormal];
    [_datePicker removeFromSuperview];
    self.dateComponentsContainerView.hidden = NO;

}

- (IBAction)toDateBtnPressed:(id)sender {
    
    self.dateComponentsContainerView.hidden = YES;
    _toDatePicker = [[UIDatePicker alloc] initWithFrame:_dateComponentsContainerView.frame];
    [_toDatePicker addTarget:self action:@selector(toDatePickerDidSelectTheDate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_toDatePicker];

}

- (void)toDatePickerDidSelectTheDate:(UIDatePicker *)picker{
    [_toDateBtn setTitle:[[self dateFormatter] stringFromDate:[picker date]] forState:UIControlStateNormal];
    [_toDatePicker removeFromSuperview];
    self.dateComponentsContainerView.hidden = NO;
    
}
@end
