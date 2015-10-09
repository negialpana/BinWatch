//
//  BWAnalyticsViewController.m
//  BinWatch
//
//  Created by Supritha Nagesha on 03/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWAnalyticsViewController.h"
#import "QueryParameterCell.h"
#import "BWDatePickerView.h"

static NSString *queryParameterCell = @"queryParameterCell";

@interface BWAnalyticsViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView2;
@property (nonatomic, strong) NSArray *table2Data;
@property (weak, nonatomic) IBOutlet UIButton *fromDateBtn;
@property (weak, nonatomic) IBOutlet UIButton *toDateBtn;
@property (nonatomic, strong) BWDatePickerView *datePicker;
@property (nonatomic, strong) BWDatePickerView *toDatePicker;
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

- (IBAction)fromDateBtnPressed:(id)sender {
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"BWDatePickerView" owner:self options:nil];
    _datePicker = [views objectAtIndex:0];
    __weak typeof(self) weakSelf = self;
    [_datePicker setComplBlock:^void(NSDate *selDate){
        [weakSelf.fromDateBtn setTitle:[[weakSelf dateFormatter] stringFromDate:selDate] forState:UIControlStateNormal];
    }];
    _datePicker.frame = CGRectMake(self.dateComponentsContainerView.frame.origin.x,
                                   self.dateComponentsContainerView.frame.origin.y,
                                   self.view.bounds.size.width, 250);
    [self.view addSubview:_datePicker];
    [_datePicker bringSubviewToFront:self.dateComponentsContainerView];
    
}

- (IBAction)toDateBtnPressed:(id)sender {
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"BWDatePickerView" owner:self options:nil];
    _toDatePicker = [views objectAtIndex:0];
    __weak typeof(self) weakSelf = self;
    [_toDatePicker setComplBlock:^void(NSDate *selDate){
        [weakSelf.toDateBtn setTitle:[[weakSelf dateFormatter] stringFromDate:selDate] forState:UIControlStateNormal];
    }];
    _toDatePicker.frame = CGRectMake(self.dateComponentsContainerView.frame.origin.x,
                                   self.dateComponentsContainerView.frame.origin.y,
                                   self.view.bounds.size.width, 250);
    [self.view addSubview:_toDatePicker];
    [_toDatePicker bringSubviewToFront:self.dateComponentsContainerView];

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
