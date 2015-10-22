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

#define TABLE_VIEW_PLACES_SEARCH 0
#define TABLE_VIEW_DISPLAY_BINS 111
#define TABLE_VIEW_ANALYTICS 222

static NSString *queryParameterCell = @"queryParameterCell";
static NSString *analyseBinCell  = @"binCellAnalyse";

static NSString *kAnalyseHeader  = @"Select Parameter";
static NSString *kSelectHeader   = @"Select Bins";

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
@property (nonatomic, strong) NSMutableArray *selectedBins;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarForTableView1;

- (IBAction)dateBtnPressed:(id)sender;

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

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (tableView.tag) {
            
        case TABLE_VIEW_DISPLAY_BINS:
        {
            BWAnalyseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:analyseBinCell];
            BWBin *bin = (BWBin *)[self.table1Data objectAtIndex:indexPath.row];
            cell.binDetailsLabel.text = [BWHelpers areanameFromFullAddress:bin.place];
            cell.fillPercentLabel.text = [NSString stringWithFormat:@"%ld%%",[bin.fill longValue]];
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
            SPGooglePlacesAutocompletePlace *place = [self placeAtIndexPath:indexPath];
            [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
                if (error)
                {
                    [BWLogger DoLog:@"Could not map selected Place"];
                    [BWHelpers displayHud:kSelectedPlaceFetchFailed onView:self.navigationController.view];
                } else if (placemark)
                {
                    [self fetchDataForPlace:searchResultPlaces[indexPath.row]];
                    [self.searchDisplayController setActive:NO];
                    [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
                }
            }];
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

#pragma mark - Event Handler
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

-(void)fetchDataForPlace:(NSString*)place
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [BWHelpers displayHud:@"Loading..." onView:self.navigationController.view];
    });
    BWConnectionHandler *connectionHandler = [BWConnectionHandler sharedInstance];
    [connectionHandler getBinsAtPlace:place
                WithCompletionHandler:^(NSArray *bins, NSError *error) {
                    if (!error) {
                        NSLog(@"*********Bins: %@", [bins description]);
                        // TODO: RefreshView
                        //[self refreshBins];
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
    // TODO: RefreshView
    //[self refreshBins];
}

@end
