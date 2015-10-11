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
#import "BWAnalyseTableViewCell.h"
#import "BWAnalyseViewController.h"
#import "BWDataHandler.h"
#import "BWHelpers.h"
#import "BWBin.h"

static NSString *queryParameterCell = @"queryParameterCell";
static NSString *analyseBinCell  = @"binCellAnalyse";

@interface BWAnalyticsViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView2;
@property (weak, nonatomic) IBOutlet UITableView *tableView1;
@property (nonatomic, strong) NSArray *table1Data;
@property (nonatomic, strong) NSArray *table2Data;
@property (weak, nonatomic) IBOutlet UIButton *fromDateBtn;
@property (weak, nonatomic) IBOutlet UIButton *toDateBtn;
@property (nonatomic, strong) BWDatePickerView *datePicker;
@property (weak, nonatomic) IBOutlet UIView *dateComponentsContainerView;
@property (nonatomic, strong) NSString *queryParam;

- (IBAction)dateBtnPressed:(id)sender;

@end

@implementation BWAnalyticsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [_fromDateBtn setTitle:[[self dateFormatter] stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    [_toDateBtn setTitle:[[self dateFormatter] stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    
    self.table1Data = [[[BWDataHandler sharedHandler] fetchBins] mutableCopy];
    self.table2Data = [NSArray arrayWithObjects:@"Fill Trend", @"TBD", nil];
    
    _tableView2.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.queryParam = [self.table2Data objectAtIndex:0];
    _tableView1.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    // Do any additional setup after loading the view.
}

- (NSDateFormatter *)dateFormatter{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return formatter;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView1) {
        return [self.table1Data count];
    }else if (tableView == self.tableView2) {
        return [self.table2Data count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (tableView == _tableView1) {
        return  @"Select Bins";
    }else{
        return @"Select Query Param";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == _tableView2) {
        QueryParameterCell *cell = [tableView dequeueReusableCellWithIdentifier:queryParameterCell];
        [cell.queryString setText:[self.table2Data objectAtIndex:indexPath.row]];
        [cell.selectionBtn setSelected:[[self.table2Data objectAtIndex:indexPath.row] isEqualToString:self.queryParam]];
        return cell;
    }else{
        BWAnalyseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:analyseBinCell];
        BWBin *bin = (BWBin *)[self.table1Data objectAtIndex:indexPath.row];
        cell.binDetailsLabel.text = [BWHelpers areanameFromFullAddress:bin.place];
        cell.fillPercentLabel.text = [NSString stringWithFormat:@"%ld%%",[bin.fill longValue]];
        return cell;
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (tableView == _tableView2) {
        self.queryParam = [self.table2Data objectAtIndex:indexPath.row];
        [self.tableView2 reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)dateBtnPressed:(id)sender {
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"BWDatePickerView" owner:self options:nil];
    _datePicker = [views objectAtIndex:0];
    __weak typeof(self) weakSelf = self;
    [_datePicker setComplBlock:^void(NSDate *selDate){
        
        UIButton *btn = (UIButton *)sender;
        [btn setTitle:[[weakSelf dateFormatter] stringFromDate:selDate] forState:UIControlStateNormal];
    }];
    _datePicker.frame = CGRectMake(self.dateComponentsContainerView.frame.origin.x,
                                   self.dateComponentsContainerView.frame.origin.y,
                                   self.view.bounds.size.width, 250);
    
    [self.view addSubview:_datePicker];
    [_datePicker bringSubviewToFront:self.dateComponentsContainerView];
    
    [UIView animateWithDuration:0.3 animations:^{
        [_datePicker setAlpha:1.0];
    }];
    
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
     if ([segue.identifier isEqualToString:@"AnalyzeSegue"]) {
         BWAnalyseViewController *dvc = segue.destinationViewController;
         
         //IMP TODO: Change the data later dynamic
         
         dvc.bins = [NSArray arrayWithObjects:@"Bin1",@"Bin2", nil];
         dvc.query = self.queryParam;
         dvc.fromDate = [[self dateFormatter] dateFromString:_fromDateBtn.titleLabel.text];
         dvc.toDate = [[self dateFormatter] dateFromString:_toDateBtn.titleLabel.text];
     }
 }
 

@end
