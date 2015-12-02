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
#define LINE_VIEW_TAG_START_VAL         500
#define BAR_GRAPH_TAG_START_VAL        1000
#define MAX_GRAPHS_TO_BE_RENDERED       7

@interface BinDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeFrameLabel;
@property (nonatomic, retain) BWBin *currentBin;
@property (nonatomic, retain) NSArray *currentBinHumidityData;
@property (nonatomic, retain) NSArray *currentBinTemperatureData;
@property (nonatomic, strong) BWDatePickerView *datePicker;
@property (nonatomic, retain) NSArray *finalBinTemperatureData;
@property (weak, nonatomic) IBOutlet UIView *dateComponentsContainerView;
@property (weak, nonatomic) IBOutlet UIButton *fromDateBtn;
@property (weak, nonatomic) IBOutlet UIButton *toDateBtn;
@property (weak, nonatomic) IBOutlet UIButton *customViewBinIdBtn;
@property (weak, nonatomic) IBOutlet UIButton *customViewGraphDismissBtn;

- (IBAction)customViewBinIdBtnClicked:(id)sender;
- (IBAction)customViewDismissGraphBtnClicked:(id)sender;

@end

@implementation BinDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initVars];
    [self setUpView];
    [self setNextFill];
    [self setUpBarGraphView];
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
    [_customViewGraphDismissBtn setHidden:YES];
    NSLog(@"segmented control tapped with index %ld", (long)_segmentControl.selectedSegmentIndex);
    
    switch ([_segmentControl selectedSegmentIndex]) {
        case 0:
        {
            [_weekView setHidden:NO];
            [_customDateView setHidden:YES];
            [self setUpBarGraphView];
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

- (IBAction)customViewBinIdBtnClicked:(id)sender
{
    [self.weekView setHidden:NO];
    [self.customDateView setHidden:YES];
    [self.customViewGraphDismissBtn setHidden:NO];
    
    NSDate *fromDate = [[self dateFormatter] dateFromString:[[_fromDateBtn titleLabel] text]];
    NSDate *toDate = [[self dateFormatter] dateFromString:[[_toDateBtn titleLabel] text]];
    [self getCurrentBinDataFromDate:fromDate toDate:toDate];
}

- (IBAction)customViewDismissGraphBtnClicked:(id)sender
{
    [self.weekView setHidden:YES];
    [self.customDateView setHidden:NO];
}

#pragma mark - Week Segment Methods

- (void)initVars
{
    _currentBinHumidityData = nil;
    _currentBinTemperatureData = nil;
    _finalBinTemperatureData = nil;
}

- (void)setUpView
{
    self.currentBin = [[[BWDataHandler sharedHandler] fetchBins] objectAtIndex:_currentSelectedBinIndex];

    // TODO: hack for iOS9
    if (self.currentBin == nil)
        self.currentBin = [[[BWBinCollection sharedInstance] bins]objectAtIndex:_currentSelectedBinIndex];
    
    [self setUpBgColorForBinIdView : _binIDView];
    
    [_binLocationLabel setAdjustsFontSizeToFitWidth:YES];
    [_binLocationLabel setText:self.currentBin.place];
    [_binFillPercentLabel setText:[NSString stringWithFormat:@"%ld %%", (long)[self.currentBin.fill integerValue]]];
}

- (void)setUpBarGraphView
{
    NSDate *today = [NSDate date];
    NSDate *sevenDaysAgo = [today dateByAddingTimeInterval:- 7*24*60*60];
    [self getCurrentBinDataFromDate:sevenDaysAgo toDate:today];
}

- (void)getCurrentBinDataFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
    [self setTimeFrameLabelWith:fromDate andEndDate:toDate];
    
    //get temperature data
    [[BWConnectionHandler sharedInstance] getBinData:self.currentBin.binID from:fromDate to:toDate forParam:BWTemperature
                               WithCompletionHandler:^(NSArray *binData, NSError *error) {
                                   
                                   if (!error) {
                                        _currentBinTemperatureData = binData;
                                       
                                       //get humidity data after temperature data is fetched
                                       [[BWConnectionHandler sharedInstance] getBinData:self.currentBin.binID from:fromDate to:toDate forParam:BWHumidity
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
            dispatch_async(dispatch_get_main_queue(), ^{
                self.nextFillDate.text = text;
            });

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
    
    NSMutableArray *modifiedBinHumidityData = nil;
    
    //plot only 7 graphs at a time for now, in case the data values are more than that, then create group of values based on total count, and the averge the values belonging to one group

    NSArray *finalHumidityDataArray = _currentBinHumidityData;
    if([_currentBinHumidityData count] > 7)
    {
        modifiedBinHumidityData = [self getModifiedDataForCurrentData:_currentBinHumidityData forParam:BWHumidity];
        
        if(modifiedBinHumidityData)
            finalHumidityDataArray = modifiedBinHumidityData;
    }
    
    //plot graphs
    
    if([finalHumidityDataArray count] <= 0)
        return;
    
    for (int i = 0; i < [finalHumidityDataArray count]; i++) {
        CGRect barGraphViewFrame = _blackLineImageView.frame;
        
        int humidityLevelForPlots = 0;
        if(modifiedBinHumidityData)
            humidityLevelForPlots = [[finalHumidityDataArray objectAtIndex:i]intValue];
        else
            humidityLevelForPlots = [[[finalHumidityDataArray objectAtIndex:i]objectForKey:@"humidity"]intValue];
        
        if(humidityLevelForPlots < 0)
            humidityLevelForPlots = 0;
        
        UIView *prevView = [_barGraphView viewWithTag:BAR_GRAPH_TAG_START_VAL+i];
        if(prevView)
            [prevView removeFromSuperview];
        
        [BWViewRenderingHelper addBarGraphOnView:_barGraphView atOrigin:CGPointMake(offsetX + (BAR_VIEW_WIDTH_WITH_SPACING * i), barGraphViewFrame.origin.y) withFillLevel:humidityLevelForPlots andTag:BAR_GRAPH_TAG_START_VAL+i];
    }
}

- (NSMutableArray *)getModifiedDataForCurrentData:(NSArray*)currentData forParam:(BWBinParam)param
{
    int humdityValueForModifiedData = 0;
    NSMutableArray *modifiedData = nil;
    modifiedData = [NSMutableArray array];
    
    NSString *parameterType = nil;
    switch (param) {
        case BWHumidity:
            parameterType = @"humidity";
            break;
            
        case BWTemperature:
            parameterType = @"temperature";
            break;
            
        default:
            break;
    }
    
    int totalItemsInOneGroup = ceil([currentData count]/(float)MAX_GRAPHS_TO_BE_RENDERED);
    
    for (int i = 1; i <= [currentData count]; i++) {
        humdityValueForModifiedData += [[[currentData objectAtIndex:i-1]objectForKey:parameterType]intValue];
        if(i % totalItemsInOneGroup == 0)
        {
            humdityValueForModifiedData /= totalItemsInOneGroup;
            [modifiedData addObject:[NSNumber numberWithInt:humdityValueForModifiedData]];
            humdityValueForModifiedData = 0;
        }
    }
    
    return modifiedData;
}
- (void)setUpTemperatureGraph
{
    float offsetY = 20.0f;
    float offsetX = 17.0f;
    
    NSMutableArray *modifiedBinTemperatureData = nil;

    _finalBinTemperatureData = _currentBinTemperatureData;
    
    if([_currentBinTemperatureData count] > 7)
    {
        modifiedBinTemperatureData = [self getModifiedDataForCurrentData:_currentBinTemperatureData forParam:BWTemperature];
        
        if(modifiedBinTemperatureData)
            _finalBinTemperatureData = modifiedBinTemperatureData;
    }
    
    if([_finalBinTemperatureData count] <= 0)
        return;
    
    for (int i = 0; i < [_finalBinTemperatureData count]; i++) {
        CGRect barGraphViewFrame = _blackLineImageView.frame;
        
        int temperatureLevelForPlots = 0;
        if(modifiedBinTemperatureData)
            temperatureLevelForPlots = [[_finalBinTemperatureData objectAtIndex:i]intValue];
        else
            temperatureLevelForPlots = [[[_finalBinTemperatureData objectAtIndex:i]objectForKey:@"temperature"]intValue];
        
        if(temperatureLevelForPlots < 0)
            temperatureLevelForPlots = 0;
        
        //in case same view was previously rendered then remove it
        UIView *prevView = [_barGraphView viewWithTag:CIRCLE_VIEW_TAG_START_VAL+i];
        if(prevView)
            [prevView removeFromSuperview];
        
        [BWViewRenderingHelper addCircleOnView:_barGraphView atOrigin:CGPointMake(offsetX + (BAR_VIEW_WIDTH_WITH_SPACING * i), barGraphViewFrame.origin.y - offsetY - temperatureLevelForPlots) andTag:CIRCLE_VIEW_TAG_START_VAL+i];
    }
}

- (void)joinCirclesWithLine
{
    if([_finalBinTemperatureData count] <= 0)
        return;
    
    for (int i = 0; i < [_finalBinTemperatureData count] - 1; i++)
    {
        UIView *circleView1 = [_barGraphView viewWithTag:CIRCLE_VIEW_TAG_START_VAL+i];
        UIView *circleView2 = [_barGraphView viewWithTag:CIRCLE_VIEW_TAG_START_VAL+i+1];
        
        CGPoint circleCenter1 = CGPointMake(circleView1.frame.origin.x + circleView1.frame.size.width * 0.5f, circleView1.frame.origin.y + circleView1.frame.size.height * 0.5f);
        CGPoint circleCenter2 = CGPointMake(circleView2.frame.origin.x + circleView2.frame.size.width * 0.5f, circleView2.frame.origin.y + circleView2.frame.size.height * 0.5f);
        
        CALayer *prevLayer = nil;
        
        for (CALayer *layer in _barGraphView.layer.sublayers) {
            NSString *shapeLayerName = [NSString stringWithFormat:@"%d",LINE_VIEW_TAG_START_VAL+i];
            if([[layer name] isEqualToString:shapeLayerName])
            {
                prevLayer = layer;
                break;
            }
        }
        if(prevLayer)
            [prevLayer removeFromSuperlayer];

        [BWViewRenderingHelper joinCircleCenters:circleCenter1 and:circleCenter2 onView:_barGraphView andTag:LINE_VIEW_TAG_START_VAL+i];
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
    [_customViewGraphDismissBtn setHidden:YES];
    //init dates
    NSString *today = [[self dateFormatter] stringFromDate:[NSDate date]];
    [_fromDateBtn setTitle:today forState:UIControlStateNormal];
    [_toDateBtn setTitle:today forState:UIControlStateNormal];
    
    //init labels
    NSString *title = [NSString stringWithFormat:@"%@ \t\t\t\t\t %ld %%", [BWHelpers areanameFromFullAddress:self.currentBin.place], (long)[self.currentBin.fill integerValue]];
    [_customViewBinIdBtn setTitle: title forState:UIControlStateNormal];
    
    [self setUpBgColorForBinIdView : _customViewBinIdBtn];
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
    [_datePicker.doneBtn setEnabled:NO];
    [_datePicker.doneBtn setTintColor:[UIColor clearColor]];
    _datePicker.shouldRemoveFromSuperview = NO;
    _datePicker.frame = CGRectMake(self.dateComponentsContainerView.frame.origin.x,
                                   self.dateComponentsContainerView.frame.origin.y + self.dateComponentsContainerView.frame.size.width * 0.20f,
                                   self.dateComponentsContainerView.bounds.size.width, 250);
    [_datePicker.datePickerView addTarget:self action:@selector(datePickerSelectDate:) forControlEvents:UIControlEventValueChanged];
    [self.fromDateBtn setTitle:[[self dateFormatter] stringFromDate:[self dateByAddingDays:-7]] forState:UIControlStateNormal];
    
    __weak typeof(self) weakSelf = self;
    [_datePicker setComplBlock:^void(NSDate *selDate){
        [weakSelf.fromDateBtn setTitle:[[weakSelf dateFormatter] stringFromDate:selDate] forState:UIControlStateNormal];
    }];
    
    [self.customDateView addSubview:_datePicker];
    
    [_datePicker bringSubviewToFront:self.dateComponentsContainerView];
}

- (void)datePickerSelectDate:(UIDatePicker *)picker{
    [self.fromDateBtn setTitle:[[self dateFormatter] stringFromDate:picker.date] forState:UIControlStateNormal];
}

- (NSDate *)dateByAddingDays:(NSInteger)days
{
    NSDateComponents *dayComponents = [[NSDateComponents alloc] init];
    [dayComponents setDay:days];
    return [[NSCalendar currentCalendar] dateByAddingComponents:dayComponents toDate:[NSDate date] options:0];
}


@end
