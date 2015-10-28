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
#import "BWDatePickerView.h"

#define BAR_VIEW_WIDTH_WITH_SPACING     43.0f
#define CIRCLE_VIEW_TAG_START_VAL       100
#define MAX_GRAPHS_TO_BE_RENDERED       7

@interface BinDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeFrameLabel;
@property (nonatomic, retain) BWBin *currentBin;
@property (nonatomic, retain) NSArray *currentBinHumidityData;
@property (nonatomic, retain) NSArray *currentBinTemperatureData;
@property (nonatomic, strong) BWDatePickerView *datePicker;
@property (weak, nonatomic) IBOutlet UIView *dateComponentsContainerView;
@property (weak, nonatomic) IBOutlet UIButton *fromDateBtn;
@property (weak, nonatomic) IBOutlet UIButton *toDateBtn;
@property (weak, nonatomic) IBOutlet UIView *customViewBinId;
@property (weak, nonatomic) IBOutlet UILabel *customViewBinLocLabel;
@property (weak, nonatomic) IBOutlet UILabel *customViewBillFillPerLabel;

@end

@implementation BinDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initVars];
    [self setUpView];
    [self setNextFill];
    [self getCurrentBinData];
    [self initCustomView];
    
    [_weekView setHidden:NO];
    [_customDateView setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addDatePicker];
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
    NSLog(@"segmented control tapped with index %ld", (long)_segmentControl.selectedSegmentIndex);
    
    switch ([_segmentControl selectedSegmentIndex]) {
        case 0:
        {
            [_weekView setHidden:NO];
            [_customDateView setHidden:YES];
        }
            break;
            
        case 1:
        {
            [_weekView setHidden:YES];
            [_customDateView setHidden:NO];
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)dateSelectButtonPressed:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [_datePicker setComplBlock:^void(NSDate *selDate){
        
        UIButton *btn = (UIButton *)sender;
        [btn setTitle:[[weakSelf dateFormatter] stringFromDate:selDate] forState:UIControlStateNormal];
    }];
}

#pragma mark - Week Segment Methods

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
    
    [self setUpBgColorForBinIdView : _binIDView];
    
    [_binLocationLabel setText:[BWHelpers areanameFromFullAddress:self.currentBin.place]];
    [_binFillPercentLabel setText:[NSString stringWithFormat:@"%ld %%", (long)[self.currentBin.fill integerValue]]];
}

- (void)getCurrentBinData
{
    NSDate *today = [NSDate date];
    NSDate *sevenDaysAgo = [today dateByAddingTimeInterval:- 7*24*60*60];
    
    [self setTimeFrameLabelWith:sevenDaysAgo andEndDate:today];
    
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

- (void)setTimeFrameLabelWith:(NSDate *)startDate andEndDate:(NSDate*)endDate
{
    NSDateComponents *startDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:startDate];
    int startDay = [startDateComponents day];
    int startMonth = [startDateComponents month];
    NSString *startMonthName = [([[[NSDateFormatter alloc] init] monthSymbols][startMonth - 1]) substringToIndex:3];
    int startYear = [startDateComponents year];
    
    NSDateComponents *endDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:endDate];
    
    int endDay = [endDateComponents day];
    int endMonth = [endDateComponents month];
    NSString *endMonthName = [([[[NSDateFormatter alloc] init] monthSymbols][endMonth - 1]) substringToIndex:3];
    int endYear = [endDateComponents year];
    
    NSString *labelString = [NSString stringWithFormat:@"%d %@ - %d %@", startDay, startMonthName, endDay, endMonthName];
    
    if([startDate compare:endDate] == NSOrderedSame)
        labelString = [NSString stringWithFormat:@"%d %@", startDay, endMonthName];
    if(startYear != endYear)
        labelString = [NSString stringWithFormat:@"%d %@ %d - %d %@ %d", startDay, startMonthName, startYear, endDay, endMonthName, endYear];
    
    [self.timeFrameLabel setText:labelString];
}

- (void)plotGraphs
{
    [self setUpBarGraphViews];
    [self setUpTemperatureGraph];
    [self joinCirclesWithLine];
}

-(void)setNextFill
{
    // init datetime formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"dd-MM-yyyy"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    __block NSString *text;
    [[BWConnectionHandler sharedInstance] getNextFillForBinWithId:self.currentBin.binID andCompletionBlock:^(NSDate *next, NSError *error) {
        if (!error) {
            text = [dateFormatter stringFromDate:next];
            self.nextFillDate.text = text;
        }
        else {
            [BWLogger DoLog:@"Failed to get next fill date"];
            [BWHelpers displayHud:@"Failed to get next fill date" onView:self.view];
        }
    }];
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

- (void)setUpBgColorForBinIdView : (UIView*) binIdView
{
    if([self.currentBin.fill integerValue] > RED_BOUNDARY)
        binIdView.backgroundColor = RedColor;
    else if ([self.currentBin.fill integerValue] > YELLOW_BOUNDARY)
        binIdView.backgroundColor = YellowColor;
    else
        binIdView.backgroundColor = GreenColor;
}

#pragma mark - Custom Date Selection Methods
- (void) initCustomView
{
    //init dates
    NSString *today = [[self dateFormatter] stringFromDate:[NSDate date]];
    [_fromDateBtn setTitle:today forState:UIControlStateNormal];
    [_toDateBtn setTitle:today forState:UIControlStateNormal];
    
    //init labels
    [_customViewBinLocLabel setText:[BWHelpers areanameFromFullAddress:self.currentBin.place]];
    [_customViewBillFillPerLabel setText:[NSString stringWithFormat:@"%ld %%", (long)[self.currentBin.fill integerValue]]];
    
    [self setUpBgColorForBinIdView : _customViewBinId];
}

- (NSDateFormatter *)dateFormatter
{    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return formatter;
}

- (void)addDatePicker
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"BWDatePickerView" owner:self options:nil];
    _datePicker = [views objectAtIndex:0];
    _datePicker.removeFromSuperview = NO;
    _datePicker.frame = CGRectMake(self.dateComponentsContainerView.frame.origin.x,
                                   self.dateComponentsContainerView.frame.origin.y + self.dateComponentsContainerView.frame.size.width * 0.20f,
                                   self.dateComponentsContainerView.bounds.size.width, 250);
    
    __weak typeof(self) weakSelf = self;
    [_datePicker setComplBlock:^void(NSDate *selDate){
        
        [_fromDateBtn setTitle:[[weakSelf dateFormatter] stringFromDate:selDate] forState:UIControlStateNormal];
    }];
    
    [self.customDateView addSubview:_datePicker];
    [_datePicker bringSubviewToFront:self.dateComponentsContainerView];
}

@end
