//
//  BWFillLevelsViewController.m
//  BinWatch
//
//  Created by Supritha Nagesha on 03/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWFillLevelsViewController.h"
#import "BWConnectionHandler.h"
#import "BWDataHandler.h"
#import "BWHelpers.h"
#import "BWBin.h"
#import "GradientView.h"
#import "BinDetailsViewController.h"
#import "AppDelegate.h"

#import "MBProgressHUD.h"
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocomplete.h"
#import "BWConstants.h"
#import "BWSettingsControl.h"
#import "BWAppSettings.h"

#define NoBinsFont [UIFont fontWithName:@"Palatino-Italic" size:20]
#define TABLE_VIEW_PLACES_SEARCH 0
#define TABLE_VIEW_DISPLAY_BINS 1

const NSString *noBinsMessage = @"No data is currently available. Please pull down to refresh.";

@interface BWFillLevelsViewController () <UITableViewDataSource , UITableViewDelegate , UISearchBarDelegate ,UISearchDisplayDelegate, MBProgressHUDDelegate , BWSettingsControlDelegate >

@end

@implementation BWFillLevelsViewController

bool noBins = NO;
NSMutableArray *activeBins;
UIRefreshControl *refreshControl;
NSDate *lastUpdate;
NSArray *searchResultPlaces;
SPGooglePlacesAutocompleteQuery *searchQuery;
BWSettingsControl *settingsControl;
BOOL shouldBeginEditing;

#pragma  mark - View Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    activeBins = [[NSMutableArray alloc]init];

    // Init for google places search
    searchResultPlaces = [[NSArray alloc]init];
    searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:kGoogleAPIKey_Browser];
    shouldBeginEditing = YES;
    self.searchDisplayController.searchBar.placeholder = kSearchPlaceHolder;

    // Init Hud
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"Loading";
    
    [HUD showWhileExecuting:@selector(fetchData) onTarget:self withObject:nil animated:YES];

    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:kMoreButtonImageName] style:UIBarButtonItemStyleDone target:self action:@selector(moreTapped)];
    self.navigationItem.rightBarButtonItem = moreButton;


    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(didChangeDeviceOrientation)
               name:UIDeviceOrientationDidChangeNotification
             object:nil];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(fetchData)
             forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:refreshControl];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchDisplayController.searchResultsTableView.delegate = self;
    self.searchDisplayController.searchResultsTableView.dataSource = self;
    self.searchDisplayController.delegate = self;

    // Adding settings control
    settingsControl = [BWSettingsControl new];
    NSString *switchTo;
    if([[BWDataHandler sharedHandler] getAppMode] == BWBBMP)
        switchTo = kSwitchToUser;
    else
        switchTo = kSwitchToBBMP;

    [settingsControl createMenuInViewController:self withCells:@[kExport,kSettings,switchTo] andWidth:200];
    settingsControl.delegate = self;
    
    [self.searchBar setBackgroundImage:[[UIImage alloc]init]];
    [self.searchBar setTranslucent:NO];

}

-(void)fetchData
{
    [self fetchDataForLocation:@"Bangalore"];
}

-(void)fetchDataForLocation:(CLLocation*)location
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [BWHelpers displayHud:@"Loading..." onView:self.navigationController.view];
  });
  BWConnectionHandler *connectionHandler = [BWConnectionHandler sharedInstance];
  [connectionHandler getBinsAtPlace:location
              WithCompletionHandler:^(NSArray *bins, NSError *error) {
                if (!error) {
                  NSLog(@"*********Bins: %@", [bins description]);
                  lastUpdate = [NSDate date];
                  [self refreshBins];
                } else {
                  NSLog(@"***********Failed to get bins***************");
                  if (![[AppDelegate appDel] connected]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SHOWALERT(kNotConnectedTitle, kNotConnectedText);
                    });
                  }
                }
              }];
  [self refreshBins];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (noBins) {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = noBinsMessage;
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = NoBinsFont;
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    }
    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    long tableViewTag = (long)tableView.tag;

    if(tableViewTag == TABLE_VIEW_PLACES_SEARCH)
        return [searchResultPlaces count];
    else
        return activeBins.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    long tableViewTag = (long)tableView.tag;
    if(tableViewTag == TABLE_VIEW_PLACES_SEARCH)
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
    else
    {
        static NSString* cellIdentifier = @"CellIdentifier";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        
        BWBin *bin = [self binForRowAtIndexPath:indexPath];
        cell.textLabel.text = [BWHelpers areanameFromFullAddress:bin.place];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld%%",[bin.fill longValue]];
        
        cell.textLabel.textColor = [BWHelpers textColorForBinColor:bin.color];
        cell.detailTextLabel.textColor = [BWHelpers textColorForBinColor:bin.color];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
                                        forRowAtIndexPath:(NSIndexPath *)indexPath
{
    long tableViewTag = (long)tableView.tag;
    if(tableViewTag == TABLE_VIEW_DISPLAY_BINS)
    {
        BWBin *bin = [self binForRowAtIndexPath:indexPath];
        GradientView *gradientView = [[GradientView alloc]initWithFrame:cell.frame forfill:[bin.fill floatValue]];
        cell.backgroundView = gradientView;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    long tableViewTag = (long)tableView.tag;
    if(tableViewTag == 0)
    {
        SPGooglePlacesAutocompletePlace *place = [self placeAtIndexPath:indexPath];
        [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
            if (error)
            {
                [BWLogger DoLog:@"Could not map selected Place"];
                [BWHelpers displayHud:kSelectedPlaceFetchFailed onView:self.navigationController.view];
            } else if (placemark)
            {
                [self fetchDataForLocation:placemark.location];
                [self.searchDisplayController setActive:NO];
                [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        }];
    }
    else
    {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        BinDetailsViewController *binDetailsVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"BinDetailsViewController"];
        binDetailsVC.currentSelectedBinIndex = (int)indexPath.row;
        
        [self.navigationController pushViewController:binDetailsVC animated:YES];
    }
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

//-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        CGRect statusBarFrame =  [[UIApplication sharedApplication] statusBarFrame];
//        [UIView animateWithDuration:0.25 animations:^{
//            for (UIView *subview in self.view.subviews)
//                subview.transform = CGAffineTransformMakeTranslation(0, -(statusBarFrame.size.height+19));
//        }];
//    }
//}
//
//-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        [UIView animateWithDuration:0.25 animations:^{
//            for (UIView *subview in self.view.subviews)
//                subview.transform = CGAffineTransformIdentity;
//        }];
//    }
//}

-(void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
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

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if ([self.searchBar canResignFirstResponder]) {
        [self.searchBar resignFirstResponder];

    }
    [self.tableView reloadData];
}

- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath {
    return searchResultPlaces[indexPath.row];
}

#pragma mark - Event Handlers
- (void)moreTapped
{
    [settingsControl toggleControl];
}

#pragma mark - BWSettingsControlDelegate

- (void)didTapSettingsRow:(NSInteger)row
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSLog(@"Tapped : %d", (int)row);
    switch (row) {
        case 0:
            [center postNotificationName:kExportSelectedNotification object:nil];
            break;
        case 1:
            [center postNotificationName:kSettingsSelectedNotification object:nil];
            break;
        case 2:
            [center postNotificationName:kSwitchedToUserModeNotification object:nil];
            break;
            
        default:
            break;
    }
}
-(void)didChangeDeviceOrientation
{
    [self.tableView reloadData];
}
#pragma mark - Utility Methods
- (void) refreshBins
{
    activeBins = [[[BWDataHandler sharedHandler] fetchBins] mutableCopy];
    NSLog(@"existingBins: %lu", (unsigned long)activeBins.count);
    noBins = activeBins.count ? NO : YES;
    [self.tableView reloadData];
    
    if (refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:lastUpdate]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:Black
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        //TODO :There is a crash please fix
        //refreshControl.attributedTitle = !attributedTitle?@"":attributedTitle;
        [refreshControl endRefreshing];
    }

}

-(BWBin*)binForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BWBin *bin = (BWBin *)[activeBins objectAtIndex:indexPath.row];
    return bin;
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
