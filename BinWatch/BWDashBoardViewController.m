//
//  BWDashBoardViewController.m
//  BinWatch
//
//  Created by Supritha Nagesha on 10/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWDashBoardViewController.h"
#import "UIColor+HexColor.h"
#import "BWConstants.h"
#import "VBPieChart.h"
#import "BWDataHandler.h"
#import "BWConstants.h"
#import "BWHelpers.h"
#import "BWSettingsControl.h"
#import "AppDelegate.h"

#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocomplete.h"
#import "BWConnectionHandler.h"

#define CHART_ORIGIN_X 0
#define CHART_ORIGIN_Y 300
#define CHART_WIDTH 200
#define CHART_HEIGHT 200
#define CHART_RADIUS 3
#define CHART_HOLE_RADIUS 0.3
#define CHART_SHADOW_OPACITY 0.7

#define CHART_FILL_DIVISIONS 5
#define CHART_BINSTATUS_DIVISIONS 2
#define CHART_HUMIDITY_DIVISIONS 5
#define CHART_TEMP_DIVISIONS 5

#define COLOR_RED [UIColor colorWithHex:0xdd191daa]
#define COLOR_MAGENTA [UIColor colorWithHex:0xd81b60aa]
#define COLOR_PURPLE [UIColor colorWithHex:0x8e24aaaa]
#define COLOR_BLUE [UIColor colorWithHex:0x3f51b5aa]
#define COLOR_YELLOW [UIColor colorWithHex:0xf57c00aa]

@interface BWDashBoardViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain) VBPieChart *chart;
@property (nonatomic, retain) VBPieChart *tempchart;
@property (nonatomic, retain) VBPieChart *humiditychart;
@property (nonatomic, retain) VBPieChart *activechart;
@property (nonatomic, retain) BWSettingsControl *settingsControl;

@property (nonatomic, retain) NSArray *chartValues;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *binsLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong)NSArray *binsArray;

- (IBAction)segmentTapped:(id)sender;

@end

@implementation BWDashBoardViewController
{
    SPGooglePlacesAutocompleteQuery *searchQuery;
    BOOL shouldBeginEditing;
    NSArray *searchResultPlaces;
}

#pragma mark - Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setNeedsLayout];

    // Init labels
    [self.locationLabel setText:[BWDataHandler sharedHandler].binsAddress];
    [self.binsLabel setText:[NSString stringWithFormat:@"Bin Count : %lu",(unsigned long)[[[BWDataHandler sharedHandler]fetchBins] count]]];

    // Init segmented control
    _segmentedControl.tintColor = AppTheme;
    _binsArray = [NSArray array];
    self.segmentedControl.selectedSegmentIndex = 0;

    // Init search bar and search query classes
    searchResultPlaces = [[NSArray alloc]init];
    searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:kGoogleAPIKey_Browser];
    shouldBeginEditing = YES;
    self.searchDisplayController.searchBar.placeholder = kSearchPlaceHolder;
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.searchBar setBackgroundImage:[[UIImage alloc]init]];
    [self.searchBar setTranslucent:NO];

    // Navigation Bar Init
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:kMoreButtonImageName] style:UIBarButtonItemStyleDone target:self action:@selector(menuTapped)];
    self.navigationItem.rightBarButtonItem = menuButton;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self refreshViews];
    [self setUpChartValuesForIndex:self.segmentedControl.selectedSegmentIndex];
    [self.settingsControl hideControl];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Utility Methods

-(BWSettingsControl *)settingsControl
{
    if (!_settingsControl) {
        _settingsControl = [BWSettingsControl new];
        [_settingsControl createMenuInViewController:self withCells:@[[NSNumber numberWithInt:BWMenuItemAllBBMPDefaults]] andWidth:MENU_DEFAULT_RADIUS];
    }
    return _settingsControl;
}

-(VBPieChart *)chart{
    
    if (!_chart || ![[self.view subviews] containsObject:_chart]) {
        _chart = [[VBPieChart alloc] init];
        [self.view addSubview:_chart];
        [_chart setFrame:CGRectMake(CHART_ORIGIN_X, CHART_ORIGIN_Y, CHART_WIDTH , CHART_HEIGHT)];
        _chart.center = CGPointMake(self.view.center.x, CHART_ORIGIN_Y);
        [_chart setEnableStrokeColor:YES];
        [_chart.layer setShadowOffset:CGSizeMake(2, 2)];
        [_chart.layer setShadowRadius:CHART_RADIUS];
        [_chart.layer setShadowColor:[UIColor blackColor].CGColor];
        [_chart.layer setShadowOpacity:CHART_SHADOW_OPACITY];
        [_chart setHoleRadiusPrecent:CHART_HOLE_RADIUS];
        [_chart setLabelsPosition:VBLabelsPositionOnChart];

    }
    return _chart;
}

-(VBPieChart *)activechart{
    if (!_activechart || ![[self.view subviews] containsObject:_activechart]) {
        _activechart = [[VBPieChart alloc] init];
        [self.view addSubview:_activechart];
        [_activechart setFrame:CGRectMake(CHART_ORIGIN_X, CHART_ORIGIN_Y, CHART_WIDTH , CHART_HEIGHT)];
        _activechart.center = CGPointMake(self.view.center.x, CHART_ORIGIN_Y);
        [_activechart setEnableStrokeColor:YES];
        [_activechart.layer setShadowOffset:CGSizeMake(2, 2)];
        [_activechart.layer setShadowRadius:CHART_RADIUS];
        [_activechart.layer setShadowColor:[UIColor blackColor].CGColor];
        [_activechart.layer setShadowOpacity:CHART_SHADOW_OPACITY];
        [_activechart setHoleRadiusPrecent:CHART_HOLE_RADIUS];
        [_activechart setLabelsPosition:VBLabelsPositionOnChart];
    }
    return _activechart;
}

- (VBPieChart *)humiditychart{
    if (!_humiditychart || ![[self.view subviews] containsObject:_humiditychart]) {
        _humiditychart = [[VBPieChart alloc] init];
        [self.view addSubview:_humiditychart];
        [_humiditychart setFrame:CGRectMake(CHART_ORIGIN_X, CHART_ORIGIN_Y, CHART_WIDTH , CHART_HEIGHT)];
        _humiditychart.center = CGPointMake(self.view.center.x, CHART_ORIGIN_Y);
        [_humiditychart setEnableStrokeColor:YES];
        [_humiditychart.layer setShadowOffset:CGSizeMake(2, 2)];
        [_humiditychart.layer setShadowRadius:CHART_RADIUS];
        [_humiditychart.layer setShadowColor:[UIColor blackColor].CGColor];
        [_humiditychart.layer setShadowOpacity:CHART_SHADOW_OPACITY];
        [_humiditychart setHoleRadiusPrecent:CHART_HOLE_RADIUS];
        [_humiditychart setLabelsPosition:VBLabelsPositionOnChart];
    }
    return _humiditychart;
}

- (VBPieChart *)tempchart{
    
    if (!_tempchart || ![[self.view subviews] containsObject:_tempchart]) {
        _tempchart = [[VBPieChart alloc] init];
        [self.view addSubview:_tempchart];
        [_tempchart setFrame:CGRectMake(CHART_ORIGIN_X, CHART_ORIGIN_Y, CHART_WIDTH , CHART_HEIGHT)];
        _tempchart.center = CGPointMake(self.view.center.x, CHART_ORIGIN_Y);
        [_tempchart setEnableStrokeColor:YES];
        [_tempchart.layer setShadowOffset:CGSizeMake(2, 2)];
        [_tempchart.layer setShadowRadius:CHART_RADIUS];
        [_tempchart.layer setShadowColor:[UIColor blackColor].CGColor];
        [_tempchart.layer setShadowOpacity:CHART_SHADOW_OPACITY];
        [_tempchart setHoleRadiusPrecent:CHART_HOLE_RADIUS];
        [_tempchart setLabelsPosition:VBLabelsPositionOnChart];
    }
    return _tempchart;
}

- (void)setUpChartValuesForIndex:(NSInteger)index{
    
    switch (index) {
        case 0:
            [self setUpChartValuesForFillPercent];
            break;
        case 1:
            [self setUpChartValuesForActiveInactive];
            break;
        case 2:
            [self setUpChartValuesForHumidity];
            break;
        case 3:
            [self setUpChartValuesForTemperature];
            break;
            
        default:
            break;
    }
}

-(NSArray *)getBins{
    return [[BWDataHandler sharedHandler] fetchBins];
}

- (void)setUpChartValuesForFillPercent{
    
    NSArray * bins = [self getBins];
    NSMutableArray * percentages  = [NSMutableArray array];
    
    if ([bins count]) {
        [self.binsLabel setText:[NSString stringWithFormat:@"Total Bins : %lu",(unsigned long)[bins count]]];

        for(int i = 0 ;i < CHART_FILL_DIVISIONS ;i++){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.fill < %d && SELF.fill >= %d)",(i+1)*20,(i)*20];
            //NSLog(@"....%d & %d",(i+1)*20,(i)*20);
            NSArray *arr = [bins filteredArrayUsingPredicate:predicate];
            long double percent = ((long double)[arr count]/(long double)[bins count]*100);
            
            NSDictionary *dict = @{@"Percent": [NSString stringWithFormat:@"%2.2Lf",percent],
                                   @"Count":[NSString stringWithFormat:@"%lu",(unsigned long)[arr count]]};
            [percentages addObject:dict];
        }
        self.chartValues = @[
                             @{@"name":[NSString stringWithFormat:@"< 20%% : %@",[[percentages objectAtIndex:0] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:0] valueForKey:@"Percent"], @"color":COLOR_RED},
                             @{@"name":[NSString stringWithFormat:@"< 40%% : %@",[[percentages objectAtIndex:1] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:1] valueForKey:@"Percent"], @"color":COLOR_MAGENTA},
                             @{@"name":[NSString stringWithFormat:@"< 60%% : %@",[[percentages objectAtIndex:2] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:2] valueForKey:@"Percent"], @"color":COLOR_PURPLE},
                             @{@"name":[NSString stringWithFormat:@"< 80%% : %@",[[percentages objectAtIndex:3] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:3] valueForKey:@"Percent"], @"color":COLOR_BLUE},
                             @{@"name":[NSString stringWithFormat:@"< 100%% : %@",[[percentages objectAtIndex:4] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:4] valueForKey:@"Percent"], @"color":COLOR_YELLOW}
                             ];
        
        [self.chart setChartValues:_chartValues animation:YES];

    }
   
}

- (void)setUpChartValuesForActiveInactive{
    
    NSArray * bins = [self getBins];
    NSMutableArray * percentages  = [NSMutableArray array];
    
    if ([bins count]) {
        [self.binsLabel setText:[NSString stringWithFormat:@"Total Bins : %lu",(unsigned long)[bins count]]];

        for(int i = 0 ;i < CHART_BINSTATUS_DIVISIONS ;i++){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.isAcive == %d",i];
            NSArray *arr = [bins filteredArrayUsingPredicate:predicate];
            long double percent = ((long double)[arr count]/(long double)[bins count]*100);
            
            NSDictionary *dict = @{@"Percent": [NSString stringWithFormat:@"%2.2Lf",percent],
                                   @"Count":[NSString stringWithFormat:@"%lu",(unsigned long)[arr count]]};
            [percentages addObject:dict];
        }
        self.chartValues = @[
                             @{@"name":[NSString stringWithFormat:@"In-Active: %@",[[percentages objectAtIndex:0] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:0] valueForKey:@"Percent"], @"color":COLOR_RED},
                             @{@"name":[NSString stringWithFormat:@"Active: %@",[[percentages objectAtIndex:1] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:1] valueForKey:@"Percent"], @"color":COLOR_MAGENTA}
                             ];
        
        [self.activechart setChartValues:self.chartValues animation:YES options:VBPieChartAnimationFan];
        
    }
    
}

- (void)setUpChartValuesForHumidity{
    
    NSArray * bins = [self getBins];
    NSMutableArray * percentages  = [NSMutableArray array];
    
    if ([bins count]) {
        [self.binsLabel setText:[NSString stringWithFormat:@"Total Bins : %lu",(unsigned long)[bins count]]];

        for(int i = 0 ;i < CHART_HUMIDITY_DIVISIONS ;i++){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.humidity < %d && SELF.humidity >= %d)",(i+1)*20,(i)*20];
            //NSLog(@"....%d & %d",(i+1)*20,(i)*20);
            NSArray *arr = [bins filteredArrayUsingPredicate:predicate];
            long double percent = ((long double)[arr count]/(long double)[bins count]*100);
            
            NSDictionary *dict = @{@"Percent": [NSString stringWithFormat:@"%2.2Lf",percent],
                                   @"Count":[NSString stringWithFormat:@"%lu",(unsigned long)[arr count]]};
            [percentages addObject:dict];
        }
        self.chartValues = @[
                             @{@"name":[NSString stringWithFormat:@"< 20%% : %@",[[percentages objectAtIndex:0] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:0] valueForKey:@"Percent"], @"color":COLOR_RED},
                             @{@"name":[NSString stringWithFormat:@"< 40%% : %@",[[percentages objectAtIndex:1] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:1] valueForKey:@"Percent"], @"color":COLOR_MAGENTA},
                             @{@"name":[NSString stringWithFormat:@"< 60%% : %@",[[percentages objectAtIndex:2] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:2] valueForKey:@"Percent"], @"color":COLOR_PURPLE},
                             @{@"name":[NSString stringWithFormat:@"< 80%% : %@",[[percentages objectAtIndex:3] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:3] valueForKey:@"Percent"], @"color":COLOR_BLUE},
                             @{@"name":[NSString stringWithFormat:@"< 100%% : %@",[[percentages objectAtIndex:4] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:4] valueForKey:@"Percent"], @"color":COLOR_YELLOW}
                             ];
        
        [self.humiditychart setChartValues:_chartValues animation:YES];
        
    }

}

- (void)setUpChartValuesForTemperature{
    
    NSArray * bins = [self getBins];
    NSMutableArray * percentages  = [NSMutableArray array];
    
    if ([bins count]) {
        [self.binsLabel setText:[NSString stringWithFormat:@"Total Bins : %lu",(unsigned long)[bins count]]];
        for(int i = 0 ;i < CHART_TEMP_DIVISIONS ;i++){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.temperature < %d && SELF.temperature >= %d)",(i+1)*20,(i)*20];
            //NSLog(@"....%d & %d",(i+1)*20,(i)*20);
            NSArray *arr = [bins filteredArrayUsingPredicate:predicate];
            long double percent = ((long double)[arr count]/(long double)[bins count]*100);
            
            NSDictionary *dict = @{@"Percent": [NSString stringWithFormat:@"%2.2Lf",percent],
                                   @"Count":[NSString stringWithFormat:@"%lu",(unsigned long)[arr count]]};
            [percentages addObject:dict];
        }
        self.chartValues = @[
                             @{@"name":[NSString stringWithFormat:@"< 20%% : %@",[[percentages objectAtIndex:0] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:0] valueForKey:@"Percent"], @"color":COLOR_RED},
                             @{@"name":[NSString stringWithFormat:@"< 40%% : %@",[[percentages objectAtIndex:1] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:1] valueForKey:@"Percent"], @"color":COLOR_MAGENTA},
                             @{@"name":[NSString stringWithFormat:@"< 60%% : %@",[[percentages objectAtIndex:2] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:2] valueForKey:@"Percent"], @"color":COLOR_PURPLE},
                             @{@"name":[NSString stringWithFormat:@"< 80%% : %@",[[percentages objectAtIndex:3] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:3] valueForKey:@"Percent"], @"color":COLOR_BLUE},
                             @{@"name":[NSString stringWithFormat:@"< 100%% : %@",[[percentages objectAtIndex:4] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:4] valueForKey:@"Percent"], @"color":COLOR_YELLOW}
                             ];
        
        [self.tempchart setChartValues:_chartValues animation:YES];
        
    }

}

-(void) refreshViews
{
    runOnMainThread(^{
        NSArray *bins = [[BWDataHandler sharedHandler] fetchBins];
        [self.locationLabel setText:[BWDataHandler sharedHandler].binsAddress];
        [self.binsLabel setText:[NSString stringWithFormat:@"Bin Count : %lu",(unsigned long)[bins count]]];
        [self setUpChartValuesForIndex:self.segmentedControl.selectedSegmentIndex];
    });
}
- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath {
    return searchResultPlaces[indexPath.row];
}

-(void)fetchDataForPlace:(CLLocation*)location withAddress:addressString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [BWHelpers displayHud:@"Loading..." onView:self.navigationController.view];
    });
    BWConnectionHandler *connectionHandler = [BWConnectionHandler sharedInstance];
    [connectionHandler getBinsAtPlace:location withAddress:addressString
                WithCompletionHandler:^(NSArray *bins, NSError *error) {
                    if (!error) {
                        [self refreshViews];
                    } else {
                        if (![[AppDelegate appDel] connected]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                SHOWALERT(kNotConnectedTitle, kNotConnectedText);
                            });
                        }
                        else
                        {
                            [BWHelpers displayHud:kBinFetchFailed onView:self.navigationController.view];
                        }
                    }
                }];
    //[self refreshViews];
}
#pragma mark - Event Handlers
- (void)menuTapped
{
    [self.settingsControl toggleControl];
}

- (IBAction)segmentTapped:(id)sender {
    UISegmentedControl *segmentCtrl = (UISegmentedControl *)sender;
    for(UIView *chart in [self.view subviews]){
        
        if ([chart isKindOfClass:[VBPieChart class]]) {
            [chart removeFromSuperview];
        }
    }
    [self setUpChartValuesForIndex:segmentCtrl.selectedSegmentIndex];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [searchResultPlaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"SPGooglePlacesAutocompleteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if(indexPath.row == 0)
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    else
        cell.textLabel.font = [UIFont fontWithName:@"GillSans" size:16.0];
    cell.textLabel.text = [self placeAtIndexPath:indexPath].name;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == 0)
    {
        [self fetchDataForPlace:[BWDataHandler sharedHandler].myLocation withAddress:[BWDataHandler sharedHandler].myLocationAddress];
        // ref: https://github.com/chenyuan/SPGooglePlacesAutocomplete/issues/10
        [self.searchDisplayController setActive:NO];
        [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else
    {
        SPGooglePlacesAutocompletePlace *place = [self placeAtIndexPath:indexPath];
        [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
            if (error)
            {
                [BWLogger DoLog:@"Could not map selected Place"];
                [BWHelpers displayHud:kSelectedPlaceFetchFailed onView:self.navigationController.view];
            } else if (placemark)
            {
                [self fetchDataForPlace:placemark.location withAddress:addressString];
                [self.searchDisplayController setActive:NO];
                [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        }];
    }
}

#pragma mark - UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![searchBar isFirstResponder]) {
        // User tapped the 'clear' button.
        shouldBeginEditing = NO;
        [self.searchDisplayController setActive:NO];
        //[self.mapView removeAnnotation:selectedPlaceAnnotation];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (shouldBeginEditing) {
        // Animate in the table view.
        NSTimeInterval animationDuration = 0.3;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        self.searchDisplayController.searchResultsTableView.alpha = 0.75;
        [UIView commitAnimations];
        
        [self.searchDisplayController.searchBar setShowsCancelButton:YES animated:YES];
    }
    BOOL boolToReturn = shouldBeginEditing;
    shouldBeginEditing = YES;
    return boolToReturn;
}

#pragma mark - UISearchDisplayDelegate

- (void)handleSearchForSearchString:(NSString *)searchString {
    searchQuery.location = [[BWDataHandler sharedHandler] getMyLocation].coordinate;
    searchQuery.input = searchString;
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        if (error) {
            [BWLogger DoLog:@"Could not fetch Places"];
            [BWHelpers displayHud:kPlacesFetchFailed onView:self.navigationController.view];
        } else {
            searchResultPlaces = places;
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self handleSearchForSearchString:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
