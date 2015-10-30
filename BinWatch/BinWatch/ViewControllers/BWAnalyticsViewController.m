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
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocomplete.h"
#import "BWConnectionHandler.h"
#import "GradientView.h"
#import "BWSettingsControl.h"
#import "AppDelegate.h"

#define TABLE_VIEW_PLACES_SEARCH 0
#define TABLE_VIEW_DISPLAY_BINS 111
#define TABLE_VIEW_ANALYTICS 222

static NSString *queryParameterCell = @"queryParameterCell";
static NSString *analyseBinCell  = @"binCellAnalyse";

static NSString *kAnalyseHeader  = @"Select Parameter";
static NSString *kSelectHeader   = @"Select Bins";

@interface BWAnalyticsViewController ()<UITableViewDataSource,UITableViewDelegate >
@property (weak, nonatomic) IBOutlet UITableView *tableView2;
@property (weak, nonatomic) IBOutlet UITableView *tableView1;
@property (nonatomic, strong) NSArray *table1Data;
@property (nonatomic, strong) NSArray *table2Data;
@property (weak, nonatomic) IBOutlet UIButton *fromDateBtn;
@property (weak, nonatomic) IBOutlet UIButton *toDateBtn;
@property (nonatomic, strong) BWDatePickerView *datePicker;
@property (weak, nonatomic) IBOutlet UIView *dateComponentsContainerView;
@property (nonatomic, strong) NSString *queryParam;
@property (nonatomic, strong) NSMutableArray *selectedBins;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarForTableView1;
@property (nonatomic, strong) BWSettingsControl *settingsControl;

@property (nonatomic, strong) NSMutableArray *binsDataArray;

- (IBAction)dateBtnPressed:(id)sender;
- (IBAction)donePressed:(id)sender;

@end

@implementation BWAnalyticsViewController
{
    SPGooglePlacesAutocompleteQuery *searchQuery;
    BOOL shouldBeginEditing;
    NSArray *searchResultPlaces;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(binDataChanged:) name:kBinDataChangedNotification object:nil];

    searchResultPlaces = [[NSArray alloc]init];
    searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:kGoogleAPIKey_Browser];
    shouldBeginEditing = YES;
    self.searchDisplayController.searchBar.placeholder = kSearchPlaceHolder;
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.searchBar setBackgroundImage:[[UIImage alloc]init]];
    [self.searchBar setTranslucent:NO];

    [_fromDateBtn setTitle:[[self dateFormatter] stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    [_toDateBtn setTitle:[[self dateFormatter] stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    
    self.table1Data = [[[BWDataHandler sharedHandler] fetchBins] mutableCopy];
    self.table2Data = [NSArray arrayWithObjects:@"Fill Trend", @"TBD", nil];
    
    _tableView2.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.queryParam = [self.table2Data objectAtIndex:0];
    _tableView1.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.selectedBins = [NSMutableArray array];

    // Navigation Bar Init
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:kMoreButtonImageName] style:UIBarButtonItemStyleDone target:self action:@selector(menuTapped)];
    self.navigationItem.rightBarButtonItem = menuButton;

}

-(void)viewWillAppear:(BOOL)animated
{
    // Adding settings control
    [self.settingsControl hideControl];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getters
-(BWSettingsControl *)settingsControl
{
    if (!_settingsControl) {
        _settingsControl = [BWSettingsControl new];
        [_settingsControl createMenuInViewController:self withCells:@[[NSNumber numberWithInt:BWMenuItemAllBBMPDefaults]] andWidth:MENU_DEFAULT_RADIUS];
    }
    return _settingsControl;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (tableView.tag) {

        case TABLE_VIEW_DISPLAY_BINS:
            return [self.table1Data count];

        case TABLE_VIEW_ANALYTICS:
            return [self.table2Data count];

        case TABLE_VIEW_PLACES_SEARCH:
            return [searchResultPlaces count];
            
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    switch (tableView.tag) {
            
        case TABLE_VIEW_DISPLAY_BINS:
            return @"Select Bins";
            
        case TABLE_VIEW_ANALYTICS:
            return @"Select Query Param";
            
        case TABLE_VIEW_PLACES_SEARCH:
            return nil;
            
        default:
            return nil;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 25.0;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    long tableViewTag = (long)tableView.tag;
    if(tableViewTag == TABLE_VIEW_DISPLAY_BINS)
    {
        BWBin *bin = (BWBin *)[self.table1Data objectAtIndex:indexPath.row];
        GradientView *gradientView = [[GradientView alloc]initWithFrame:cell.frame forfill:[bin.fill floatValue]];
        cell.backgroundView = gradientView;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (tableView.tag) {
            
        case TABLE_VIEW_DISPLAY_BINS:
        {
            BWAnalyseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:analyseBinCell];
            BWBin *bin = (BWBin *)[self.table1Data objectAtIndex:indexPath.row];

            UIImage *imageRed = [UIImage imageNamed:@"ButtonSelectedRed"];
            UIImage *imageGreen = [UIImage imageNamed:@"ButtonSelectedGreen"];
            UIImage *imageYellow = [UIImage imageNamed:@"ButtonSelectedYellow"];
            
            if([bin.fill longValue] > RED_BOUNDARY)
                [cell.selectionBtn setBackgroundImage:imageRed forState: UIControlStateSelected];
            else if([bin.fill longValue] > YELLOW_BOUNDARY)
                [cell.selectionBtn setBackgroundImage:imageYellow forState: UIControlStateSelected];
            else
                [cell.selectionBtn setBackgroundImage:imageGreen forState: UIControlStateSelected];
            
            cell.binDetailsLabel.text = [BWHelpers areanameFromFullAddress:bin.place];
            cell.fillPercentLabel.text = [NSString stringWithFormat:@"%ld%%",[bin.fill longValue]];
            cell.textLabel.textColor = [BWHelpers textColorForBinColor:bin.color];
            cell.detailTextLabel.textColor = [BWHelpers textColorForBinColor:bin.color];
            if ([self.selectedBins count]) {
                [cell.selectionBtn setSelected:[self.selectedBins containsObject:[self.table1Data objectAtIndex:indexPath.row]]];
            }
            return cell;
        }
        case TABLE_VIEW_ANALYTICS:
        {
            QueryParameterCell *cell = [tableView dequeueReusableCellWithIdentifier:queryParameterCell];
            [cell.queryString setText:[self.table2Data objectAtIndex:indexPath.row]];
            [cell.selectionBtn setSelected:[[self.table2Data objectAtIndex:indexPath.row] isEqualToString:self.queryParam]];
            return cell;
        }
        case TABLE_VIEW_PLACES_SEARCH:
        {
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
        default:
            return nil;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    switch (tableView.tag) {
            
        case TABLE_VIEW_DISPLAY_BINS:
            if ([self.selectedBins count] == 3 && ![self.selectedBins containsObject:[self.table1Data objectAtIndex:indexPath.row]])
            {
                [self.selectedBins replaceObjectAtIndex:0 withObject:[self.table1Data objectAtIndex:indexPath.row]];
                [self.selectedBins exchangeObjectAtIndex:0 withObjectAtIndex:1];
                [self.selectedBins exchangeObjectAtIndex:2 withObjectAtIndex:1];
            }
            else if ([self.selectedBins count] < 3)
            {
                [self.selectedBins addObject:[self.table1Data objectAtIndex:indexPath.row]];
            }
            [self.tableView1 reloadData];
            break;
            
        case TABLE_VIEW_ANALYTICS:
            self.queryParam = [self.table2Data objectAtIndex:indexPath.row];
            [self.tableView2 reloadData];
            break;
            
        case TABLE_VIEW_PLACES_SEARCH:
        {
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
            break;

        default:
            break;
    }
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 35)];
//    [headerView setBackgroundColor:AppTheme];
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 25)];
//    if(tableView.tag == TABLE_VIEW_DISPLAY_BINS)
//        titleLabel.text = kSelectHeader;
//    else if (tableView.tag == TABLE_VIEW_ANALYTICS)
//        titleLabel.text = kAnalyseHeader;
//    
//    titleLabel.textColor = [UIColor whiteColor];
//    [headerView addSubview:titleLabel];
//    return headerView;
//}

#pragma mark - Event Handlers
- (void)menuTapped
{
    [self.settingsControl toggleControl];
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
    
    [UIView animateWithDuration:0.1 animations:^{
        [_datePicker setAlpha:1.0];
    }];
    
}

- (IBAction)donePressed:(id)sender {
    
    NSDate *fromdate = [[self dateFormatter] dateFromString:_fromDateBtn.titleLabel.text];
    NSDate *todate = [[self dateFormatter] dateFromString:_toDateBtn.titleLabel.text];
    
    
    if ([self.selectedBins count] && ![fromdate isEqualToDate:todate]) {
        
        [self getBinDataForSelectedBinsAndPerformSegue];
        
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NOTE!"
                                                        message:@"Please make sure to choose bins and different dates for analysis"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)getBinDataForSelectedBinsAndPerformSegue{
    
    
    NSDate *fromdate = [[self dateFormatter] dateFromString:_fromDateBtn.titleLabel.text];
    NSDate *todate = [[self dateFormatter] dateFromString:_toDateBtn.titleLabel.text];
    self.binsDataArray = [NSMutableArray array];
    BWBin *bin = [self.selectedBins objectAtIndex:0];
    NSUInteger param = [self.queryParam isEqualToString:@"Fill Trend"]?BWFillPercentage:BWTemperature;
    [[BWConnectionHandler sharedInstance] getBinData:bin.binID from:fromdate to:todate forParam:param WithCompletionHandler:^(NSArray *array, NSError *error) {
        if (!error) {
            if ([array count]) {
                
                NSDictionary *dict = @{@"Bin":[self.selectedBins objectAtIndex:0],
                                       @"DataArray":array};
                [self.binsDataArray addObject:dict];

            }
            if ([self.selectedBins count] > 1) {
               BWBin *bin = [self.selectedBins objectAtIndex:1];
                [[BWConnectionHandler sharedInstance] getBinData:bin.binID from:fromdate to:todate forParam:param WithCompletionHandler:^(NSArray *array, NSError *error) {
                    
                    if (!error) {
                        if ([array count]) {
                            
                            NSDictionary *dict = @{@"Bin":[self.selectedBins objectAtIndex:1],
                                                   @"DataArray":array};
                            [self.binsDataArray addObject:dict];
                            
                        }
                        if ([self.selectedBins count] > 2) {
                            BWBin *bin = [self.selectedBins objectAtIndex:2];
                            [[BWConnectionHandler sharedInstance] getBinData:bin.binID from:fromdate to:todate forParam:param WithCompletionHandler:^(NSArray *array, NSError *error) {
                                
                                if (!error) {
                                    
                                    if ([array count]) {
                                        
                                        NSDictionary *dict = @{@"Bin":[self.selectedBins objectAtIndex:2],
                                                               @"DataArray":array};
                                        [self.binsDataArray addObject:dict];
                                        
                                    }

                                }else {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                                    message:[NSString stringWithFormat:@"%@",[error localizedDescription]]
                                                                                   delegate:nil
                                                                          cancelButtonTitle:@"OK"
                                                                          otherButtonTitles: nil];
                                    [alert show];

                                }
                                
                                if ([self.binsDataArray count]) {
                                    
                                    [self performSegueWithIdentifier:@"AnalyzeSegue" sender:nil];
                                    
                                }else{
                                    
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice!"
                                                                                    message:@"No Data available for bins in selected date ranges"
                                                                                   delegate:nil
                                                                          cancelButtonTitle:@"OK"
                                                                          otherButtonTitles: nil];
                                    [alert show];
                                }
                                
                                
                            }];
                        }else{
                            
                            if ([self.binsDataArray count]) {
                                
                                [self performSegueWithIdentifier:@"AnalyzeSegue" sender:nil];
                                
                            }else{
                                
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice!"
                                                                                message:@"No Data available for bins in selected date ranges"
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles: nil];
                                [alert show];
                            }
                        }

                    }else{
                    
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                            message:[NSString stringWithFormat:@"%@",[error localizedDescription]]
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles: nil];
                            [alert show];
                    }
                    
                }];
            }else{
                
                if ([self.binsDataArray count]) {
                    
                    [self performSegueWithIdentifier:@"AnalyzeSegue" sender:nil];
                    
                }else{
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice!"
                                                                    message:@"No Data available to analyse for bins in selected date ranges"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles: nil];
                    [alert show];
                }
            }
            
        } else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:[NSString stringWithFormat:@"%@",[error localizedDescription]]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        }

    }];
    
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
     if ([segue.identifier isEqualToString:@"AnalyzeSegue"]) {
         BWAnalyseViewController *dvc = segue.destinationViewController;
                  
         dvc.bins = [NSArray arrayWithArray:self.binsDataArray];
         dvc.query = self.queryParam;
         dvc.fromDate = [[self dateFormatter] dateFromString:_fromDateBtn.titleLabel.text];
         dvc.toDate = [[self dateFormatter] dateFromString:_toDateBtn.titleLabel.text];
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

#pragma mark - Utility Methods
- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath {
    return searchResultPlaces[indexPath.row];
}

- (NSDateFormatter *)dateFormatter{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return formatter;
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
                        [self refreshBins];
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
    [self refreshBins];
}

-(void) refreshBins
{
    self.table1Data = [[[BWDataHandler sharedHandler] fetchBins] mutableCopy];
    runOnMainThread(^{
        [self.tableView1 reloadData];
    });
}

#pragma mark - Notifications
- (void)binDataChanged:(NSNotification *)notification
{
    [self refreshBins];
}

@end
