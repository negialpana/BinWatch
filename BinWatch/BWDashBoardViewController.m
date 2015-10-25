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

#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocomplete.h"
#import "BWConnectionHandler.h"

#define CHART_ORIGIN_Y 100
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
    [self.locationLabel setText:@"TODO: mention location here"];
    _segmentedControl.tintColor = AppTheme;
    _binsArray = [NSArray array];
    
    [self setUpChartValuesForIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(binDataChanged:) name:kBinDataChangedNotification object:nil];
    
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
    
    self.settingsControl = [[BWSettingsControl alloc] init];
    [self.settingsControl createMenuInViewController:self withCells:@[[NSNumber numberWithInt:BWMenuItemAllBBMPDefaults]] andWidth:200];
}

-(void)viewWillAppear:(BOOL)animated
{
    // TODO: Enable this
    //[self refreshViews];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Utility Methods

-(VBPieChart *)chart{
    
    //[[self.view subviews] containsObject:_chart];
    if (!_chart || ![[self.view subviews] containsObject:_chart]) {
        _chart = [[VBPieChart alloc] init];
        [self.view addSubview:_chart];
        [_chart setFrame:CGRectMake(0, CHART_ORIGIN_Y, 250 , 250)];
        _chart.center = self.view.center;
        [_chart setEnableStrokeColor:YES];
        [_chart.layer setShadowOffset:CGSizeMake(2, 2)];
        [_chart.layer setShadowRadius:3];
        [_chart.layer setShadowColor:[UIColor blackColor].CGColor];
        [_chart.layer setShadowOpacity:0.7];
        [_chart setHoleRadiusPrecent:0.3];
        [_chart setLabelsPosition:VBLabelsPositionOnChart];

    }
    return _chart;
}
-(VBPieChart *)activechart{
    if (!_activechart || ![[self.view subviews] containsObject:_activechart]) {
        _activechart = [[VBPieChart alloc] init];
        [self.view addSubview:_activechart];
        [_activechart setFrame:CGRectMake(0, CHART_ORIGIN_Y, 250 , 250)];
        _activechart.center = self.view.center;
        [_activechart setEnableStrokeColor:YES];
        [_activechart.layer setShadowOffset:CGSizeMake(2, 2)];
        [_activechart.layer setShadowRadius:3];
        [_activechart.layer setShadowColor:[UIColor blackColor].CGColor];
        [_activechart.layer setShadowOpacity:0.7];
        [_activechart setHoleRadiusPrecent:0.3];
        [_activechart setLabelsPosition:VBLabelsPositionOnChart];
    }
    return _activechart;
}

- (VBPieChart *)humiditychart{
    if (!_humiditychart || ![[self.view subviews] containsObject:_humiditychart]) {
        _humiditychart = [[VBPieChart alloc] init];
        [self.view addSubview:_humiditychart];
        [_humiditychart setFrame:CGRectMake(0, CHART_ORIGIN_Y, 250 , 250)];
        _humiditychart.center = self.view.center;
        [_humiditychart setEnableStrokeColor:YES];
        [_humiditychart.layer setShadowOffset:CGSizeMake(2, 2)];
        [_humiditychart.layer setShadowRadius:3];
        [_humiditychart.layer setShadowColor:[UIColor blackColor].CGColor];
        [_humiditychart.layer setShadowOpacity:0.7];
        [_humiditychart setHoleRadiusPrecent:0.3];
        [_humiditychart setLabelsPosition:VBLabelsPositionOnChart];
    }
    return _humiditychart;
}

- (VBPieChart *)tempchart{
    
    if (!_tempchart || ![[self.view subviews] containsObject:_tempchart]) {
        _tempchart = [[VBPieChart alloc] init];
        [self.view addSubview:_tempchart];
        [_tempchart setFrame:CGRectMake(0, CHART_ORIGIN_Y, 250 , 250)];
        _tempchart.center = self.view.center;
        [_tempchart setEnableStrokeColor:YES];
        [_tempchart.layer setShadowOffset:CGSizeMake(2, 2)];
        [_tempchart.layer setShadowRadius:3];
        [_tempchart.layer setShadowColor:[UIColor blackColor].CGColor];
        [_tempchart.layer setShadowOpacity:0.7];
        [_tempchart setHoleRadiusPrecent:0.3];
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
    
    if (![_binsArray count]) {
        BWDataHandler *dbHandler = [BWDataHandler sharedHandler];
        _binsArray = [dbHandler fetchBins];
    }
    return _binsArray;
}

- (void)setUpChartValuesForFillPercent{
    
    NSArray * bins = [self getBins];
    NSMutableArray * percentages  = [NSMutableArray array];
    
    if ([bins count]) {
        [self.binsLabel setText:[NSString stringWithFormat:@"Total Bins : %lu",(unsigned long)[bins count]]];
        for(int i = 0 ;i<5 ;i++){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.fill < %d && SELF.fill >= %d)",(i+1)*20,(i)*20];
            NSLog(@"....%d & %d",(i+1)*20,(i)*20);
            NSArray *arr = [bins filteredArrayUsingPredicate:predicate];
            long double percent = ((long double)[arr count]/(long double)[bins count]*100);
            
            NSDictionary *dict = @{@"Percent": [NSString stringWithFormat:@"%2.2Lf",percent],
                                   @"Count":[NSString stringWithFormat:@"%lu",(unsigned long)[arr count]]};
            [percentages addObject:dict];
        }
        self.chartValues = @[
                             @{@"name":[NSString stringWithFormat:@"<20%% : %@",[[percentages objectAtIndex:0] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:0] valueForKey:@"Percent"], @"color":[UIColor colorWithHex:0xdd191daa]},
                             @{@"name":[NSString stringWithFormat:@"<40%% : %@",[[percentages objectAtIndex:1] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:1] valueForKey:@"Percent"], @"color":[UIColor colorWithHex:0xd81b60aa]},
                             @{@"name":[NSString stringWithFormat:@"<60%% : %@",[[percentages objectAtIndex:2] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:2] valueForKey:@"Percent"], @"color":[UIColor colorWithHex:0x8e24aaaa]},
                             @{@"name":[NSString stringWithFormat:@"<80%% : %@",[[percentages objectAtIndex:3] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:3] valueForKey:@"Percent"], @"color":[UIColor colorWithHex:0x3f51b5aa]},
                             @{@"name":[NSString stringWithFormat:@"<100%% : %@",[[percentages objectAtIndex:4] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:4] valueForKey:@"Percent"], @"color":[UIColor colorWithHex:0xf57c00aa]}
                             ];
        
        [self.chart setChartValues:_chartValues animation:YES];

    }
   
}

- (void)setUpChartValuesForActiveInactive{
    
    NSArray * bins = [self getBins];
    NSMutableArray * percentages  = [NSMutableArray array];
    
    if ([bins count]) {
        [self.binsLabel setText:[NSString stringWithFormat:@"Total Bins : %lu",(unsigned long)[bins count]]];
        for(int i = 0 ;i<2 ;i++){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.isAcive == %d",i];
            NSArray *arr = [bins filteredArrayUsingPredicate:predicate];
            long double percent = ((long double)[arr count]/(long double)[bins count]*100);
            
            NSDictionary *dict = @{@"Percent": [NSString stringWithFormat:@"%2.2Lf",percent],
                                   @"Count":[NSString stringWithFormat:@"%lu",(unsigned long)[arr count]]};
            [percentages addObject:dict];
        }
        self.chartValues = @[
                             @{@"name":[NSString stringWithFormat:@"InActive: %@",[[percentages objectAtIndex:0] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:0] valueForKey:@"Percent"], @"color":[UIColor colorWithHex:0xdd191daa]},
                             @{@"name":[NSString stringWithFormat:@"Active: %@",[[percentages objectAtIndex:1] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:1] valueForKey:@"Percent"], @"color":[UIColor colorWithHex:0xd81b60aa]}
                             ];
        
        [self.activechart setChartValues:self.chartValues animation:YES options:VBPieChartAnimationFan];
        
    }
    
}

- (void)setUpChartValuesForHumidity{
    
    NSArray * bins = [self getBins];
    NSMutableArray * percentages  = [NSMutableArray array];
    
    if ([bins count]) {
        [self.binsLabel setText:[NSString stringWithFormat:@"Total Bins : %lu",(unsigned long)[bins count]]];
        for(int i = 0 ;i<5 ;i++){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.humidity < %d && SELF.humidity >= %d)",(i+1)*20,(i)*20];
            NSLog(@"....%d & %d",(i+1)*20,(i)*20);
            NSArray *arr = [bins filteredArrayUsingPredicate:predicate];
            long double percent = ((long double)[arr count]/(long double)[bins count]*100);
            
            NSDictionary *dict = @{@"Percent": [NSString stringWithFormat:@"%2.2Lf",percent],
                                   @"Count":[NSString stringWithFormat:@"%lu",(unsigned long)[arr count]]};
            [percentages addObject:dict];
        }
        self.chartValues = @[
                             @{@"name":[NSString stringWithFormat:@"<20%% : %@",[[percentages objectAtIndex:0] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:0] valueForKey:@"Percent"], @"color":[UIColor colorWithHex:0xdd191daa]},
                             @{@"name":[NSString stringWithFormat:@"<40%% : %@",[[percentages objectAtIndex:1] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:1] valueForKey:@"Percent"], @"color":[UIColor colorWithHex:0xd81b60aa]},
                             @{@"name":[NSString stringWithFormat:@"<60%% : %@",[[percentages objectAtIndex:2] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:2] valueForKey:@"Percent"], @"color":[UIColor colorWithHex:0x8e24aaaa]},
                             @{@"name":[NSString stringWithFormat:@"<80%% : %@",[[percentages objectAtIndex:3] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:3] valueForKey:@"Percent"], @"color":[UIColor colorWithHex:0x3f51b5aa]},
                             @{@"name":[NSString stringWithFormat:@"<100%% : %@",[[percentages objectAtIndex:4] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:4] valueForKey:@"Percent"], @"color":[UIColor colorWithHex:0xf57c00aa]}
                             ];
        
        [self.humiditychart setChartValues:_chartValues animation:YES];
        
    }

}

- (void)setUpChartValuesForTemperature{
    
    NSArray * bins = [self getBins];
    NSMutableArray * percentages  = [NSMutableArray array];
    
    if ([bins count]) {
        [self.binsLabel setText:[NSString stringWithFormat:@"Total Bins : %lu",(unsigned long)[bins count]]];
        for(int i = 0 ;i<5 ;i++){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.temperature < %d && SELF.temperature >= %d)",(i+1)*20,(i)*20];
            NSLog(@"....%d & %d",(i+1)*20,(i)*20);
            NSArray *arr = [bins filteredArrayUsingPredicate:predicate];
            long double percent = ((long double)[arr count]/(long double)[bins count]*100);
            
            NSDictionary *dict = @{@"Percent": [NSString stringWithFormat:@"%2.2Lf",percent],
                                   @"Count":[NSString stringWithFormat:@"%lu",(unsigned long)[arr count]]};
            [percentages addObject:dict];
        }
        self.chartValues = @[
                             @{@"name":[NSString stringWithFormat:@"<20%% : %@",[[percentages objectAtIndex:0] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:0] valueForKey:@"Percent"], @"color":[UIColor colorWithHex:0xdd191daa]},
                             @{@"name":[NSString stringWithFormat:@"<40%% : %@",[[percentages objectAtIndex:1] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:1] valueForKey:@"Percent"], @"color":[UIColor colorWithHex:0xd81b60aa]},
                             @{@"name":[NSString stringWithFormat:@"<60%% : %@",[[percentages objectAtIndex:2] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:2] valueForKey:@"Percent"], @"color":[UIColor colorWithHex:0x8e24aaaa]},
                             @{@"name":[NSString stringWithFormat:@"<80%% : %@",[[percentages objectAtIndex:3] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:3] valueForKey:@"Percent"], @"color":[UIColor colorWithHex:0x3f51b5aa]},
                             @{@"name":[NSString stringWithFormat:@"<100%% : %@",[[percentages objectAtIndex:4] valueForKey:@"Count"]], @"value":[[percentages objectAtIndex:4] valueForKey:@"Percent"], @"color":[UIColor colorWithHex:0xf57c00aa]}
                             ];
        
        [self.tempchart setChartValues:_chartValues animation:YES];
        
    }

}

-(void) refreshViews
{
    NSLog(@"REFRESH VIEWS ****************************************************");
    runOnMainThread(^{
        NSArray *bins = [[BWDataHandler sharedHandler] fetchBins];
        [self.locationLabel setText:[BWDataHandler sharedHandler].binsAddress];
        [self.binsLabel setText:[NSString stringWithFormat:@"Bin Count : %lu",(unsigned long)[bins count]]];
        // TODO: Enable this.
        // Get index of seledted control
        //[self setUpChartValuesForIndex:0];
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
                        NSLog(@"*********Bins: %@", [bins description]);
                        [self refreshViews];
                    } else {
                        // TODO: Show Error
                        //                        NSLog(@"***********Failed to get bins***************");
                        //                        if (![[AppDelegate appDel] connected]) {
                        //                            dispatch_async(dispatch_get_main_queue(), ^{
                        //                                SHOWALERT(kNotConnectedTitle, kNotConnectedText);
                        //                            });
                        //                        }
                    }
                }];
    [self refreshViews];
}
#pragma mark - Event Handlers
- (void)menuTapped
{
    [self.settingsControl toggleControl];
}

#pragma mark - Event Handler
- (IBAction)segmentTapped:(id)sender {
    UISegmentedControl *segmentCtrl = (UISegmentedControl *)sender;
    for(UIView *chart in [self.view subviews]){
        
        if ([chart isKindOfClass:[VBPieChart class]]) {
            [chart removeFromSuperview];
        }
    }
    [self setUpChartValuesForIndex:segmentCtrl.selectedSegmentIndex];
}

#pragma mark - Notifications
- (void)binDataChanged:(NSNotification *)notification
{
    [self refreshViews];
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
