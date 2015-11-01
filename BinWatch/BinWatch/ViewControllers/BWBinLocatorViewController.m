//
//  BWBinLocatorViewController.m
//  BinWatch
//
//  Created by Supritha Nagesha on 03/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWBinLocatorViewController.h"
#import "SPGooglePlacesAutocomplete.h"
#import "BWDataHandler.h"
#import "BWBin.h"
#import "BWLogger.h"
#import "BWHelpers.h"
#import "BWAppSettings.h"
#import "BWConstants.h"
#import "BWConnectionHandler.h"
#import "AppDelegate.h"

#define DEFAULT_ZOOM_LEVEL 13
#define activeMapView [AppDelegate appDel].mapView

@interface BWBinLocatorViewController () <GMSMapViewDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *mapSearchBar;
@property (nonatomic, retain) BWSettingsControl *settingsControl;

@end

@implementation BWBinLocatorViewController
{
    //GMSMapView *activeMapView;
    BOOL firstLocationUpdate_;
    float zoomLevel;
    NSMutableDictionary *mapMarkers;
    NSMutableArray *selectedLocations;
    BOOL isMapEdited;
    BOOL searchOn;
    NSArray *searchResultPlaces;
    SPGooglePlacesAutocompleteQuery *searchQuery;
    
    BOOL shouldBeginEditing;
    
    // For distance calc
    BOOL distanceCheckInProgress;
    NSMutableArray *distances;
    NSMutableArray *locationsSearched;
    int numberOfBinsBeingChecked;
    BOOL viewDidLoad;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initMapsView];
}

-(void)viewWillAppear:(BOOL)animated
{
    // This is a hack fix.
    viewDidLoad = NO;
    if(!viewDidLoad)
        [self initMapsView];

    distanceCheckInProgress = NO;
    numberOfBinsBeingChecked = 0;
    [self.settingsControl hideControl];
    if([BWDataHandler sharedHandler].binsLocation)
        activeMapView.camera = [GMSCameraPosition cameraWithTarget:[BWDataHandler sharedHandler].binsLocation.coordinate
                                                        zoom:zoomLevel];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) initMapsView
{
    viewDidLoad = YES;
    //mapView = [AppDelegate appDel].mapView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(binDataChanged:) name:kBinDataChangedNotification object:nil];
    searchOn = NO;
    zoomLevel = DEFAULT_ZOOM_LEVEL;
    firstLocationUpdate_ = NO;
    isMapEdited = NO;
    
    distanceCheckInProgress = NO;
    numberOfBinsBeingChecked = 0;
    distances = [[NSMutableArray alloc] init];
    locationsSearched = [[NSMutableArray alloc] init];
    
    mapMarkers = [[NSMutableDictionary alloc] init];
    //currentLocation = [[CLLocation alloc] init];
    selectedLocations = [[NSMutableArray alloc] init];
    
    // Navigation Bar Init
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:kMoreButtonImageName] style:UIBarButtonItemStyleDone target:self action:@selector(menuTapped)];
    self.navigationItem.rightBarButtonItem = menuButton;
    
    // Register for orientation change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [[BWRoute sharedInstance] setDelegate:self];
    
    searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:kGoogleAPIKey_Browser];
    shouldBeginEditing = YES;
    
    // UISearchBar Init
    self.searchDisplayController.searchBar.placeholder = kSearchPlaceHolder;
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.mapSearchBar setBackgroundImage:[[UIImage alloc]init]];
    [self.mapSearchBar setTranslucent:NO];
    
    CLLocation *positionNow;
    // Load mapview to current location
    if([BWDataHandler sharedHandler].binsLocation)
        positionNow = [BWDataHandler sharedHandler].binsLocation;
    else if ([BWDataHandler sharedHandler].myLocation)
        positionNow = [BWDataHandler sharedHandler].myLocation;
    else
        positionNow = [[CLLocation alloc] initWithLatitude:12.9667 longitude:77.5667];
    
    [self recenterMapToPlacemark:positionNow];
    [self resizeMapView];
    activeMapView.delegate = self;
    
    [self drawBins];
    
    activeMapView.settings.compassButton = YES;
    activeMapView.settings.myLocationButton = YES;
    activeMapView.trafficEnabled = YES;
    activeMapView.buildingsEnabled = YES;
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        activeMapView.myLocationEnabled = YES;
    });
    
    [self.view addSubview:activeMapView];
    [self.view bringSubviewToFront:_mapSearchBar];
}

#pragma mark - getters
-(BWSettingsControl *)settingsControl
{
    if (!_settingsControl) {
        NSNumber *drawRoutes;
        NSNumber *defaults;
        if([[BWAppSettings sharedInstance] getAppMode] == BWBBMPMode){
            drawRoutes = [NSNumber numberWithInt:BWMenuItemDrawRoutes];
            defaults   = [NSNumber numberWithInt:BWMenuItemAllBBMPDefaults];
        }
        else{
            drawRoutes = [NSNumber numberWithInt:BWMenuItemRouteToNearest];
            defaults   = [NSNumber numberWithInt:BWMenuItemAllUserDefaults];
        }
        _settingsControl = [BWSettingsControl new];
        [_settingsControl createMenuInViewController:self withCells:@[drawRoutes,defaults] andWidth:MENU_DEFAULT_RADIUS];
        _settingsControl.delegate = self;
    }
    return _settingsControl;
}


#pragma mark - Event Handlers
- (void)menuTapped
{
    [self.settingsControl toggleControl];
}

#pragma mark - Map Utils
- (void) resizeMapView
{
    CGFloat mapviewOriginY;
    CGFloat mapViewHeight;

    // This is a hack fix. No idea why search bar animates to cover navigation bar on click of search.
    // I understand, thats the way it works
    if(searchOn)
    {
        //NSLog(@"TabBar Height: %f SearchBar Control Height: %f NAvigation: %f statusbar height: %f", self.tabBarController.tabBar.frame.size.height, self.searchDisplayController.searchBar.frame.size.height, self.navigationController.navigationBar.frame.size.height, [UIApplication sharedApplication].statusBarFrame.size.height);

        mapviewOriginY = self.view.frame.origin.y + [UIApplication sharedApplication].statusBarFrame.size.height + self.searchDisplayController.searchBar.frame.size.height;
        
        mapViewHeight = self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height -mapviewOriginY;
    }
    else
    {
        //NSLog(@"TabBar Height: %f SearchBar Control Height: %f NAvigation: %f statusbar height: %f", self.tabBarController.tabBar.frame.size.height, self.searchDisplayController.searchBar.frame.size.height, self.navigationController.navigationBar.frame.size.height, [UIApplication sharedApplication].statusBarFrame.size.height);

        mapviewOriginY = self.view.frame.origin.y + [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height + self.searchDisplayController.searchBar.frame.size.height;
        
        mapViewHeight = self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height -mapviewOriginY;
    }
    [activeMapView setFrame:CGRectMake(self.view.frame.origin.x, mapviewOriginY, self.view.frame.size.width, mapViewHeight)];
}

-(void) refreshMap
{
    runOnMainThread(^{
        [activeMapView clear];
    });
    [self drawBins];
}

-(void) drawRouteToNearestBin
{
    if(distanceCheckInProgress)
        return;

    distanceCheckInProgress = YES;
    [distances removeAllObjects];
    [locationsSearched removeAllObjects];

    CLLocation *currentLocation = [[BWDataHandler sharedHandler] getMyLocation];
    if(currentLocation.coordinate.longitude == 0 || currentLocation.coordinate.latitude == 0)
    {
        [self refreshMap];
        [BWLogger DoLog:@"Couldnt retrieve current location"];
        [BWHelpers displayHud:kCurrentLocationFailed onView:self.navigationController.view];
        return;
    }

    NSArray *activeBins = [[BWDataHandler sharedHandler] fetchBins];
    numberOfBinsBeingChecked = (int)[activeBins count];

    for(BWBin *bin in activeBins)
    {
        [[BWDistance sharedInstance] getDistancefrom:currentLocation to:[[CLLocation alloc] initWithLatitude:[bin.latitude floatValue] longitude:[bin.longitude floatValue]] andCompletionBlock:^(NSNumber *value, CLLocation *toLoc,NSError *error) {
            if (!error) {
                // Do Nothing
                [distances addObject:value];
                [locationsSearched addObject:toLoc];
                numberOfBinsBeingChecked--;
                distanceCheckInProgress = NO;
                if(numberOfBinsBeingChecked <= 0)
                {
                    //we are done
                    NSArray *sortedDistances = [distances sortedArrayUsingSelector:@selector(compare:)];
                    //NSLog(@"%@", sortedDistances);
                    if([sortedDistances count] <= 0 || [distances count] <= 0)
                    {
                        [BWHelpers displayHud:@"Something went wrong!" onView:self.navigationController.view];
                        return;
                    }

                    NSInteger anIndex = [distances indexOfObject:[sortedDistances objectAtIndex:0]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([locationsSearched count] > 0)
                            [self drawRouteToBin:[locationsSearched objectAtIndex:anIndex]];
                    });
                }
            }
            else
            {
            }
        }];
    }
}

-(void) drawRouteToBin:(CLLocation *)bin
{
    CLLocation *currentLocation = [[BWDataHandler sharedHandler] getMyLocation];
    if(currentLocation.coordinate.longitude == 0 || currentLocation.coordinate.latitude == 0)
    {
        [self refreshMap];
        [BWLogger DoLog:@"Couldnt retrieve current location"];
        [BWHelpers displayHud:kCurrentLocationFailed onView:self.navigationController.view];
        return;
    }
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    
    // Adding current locations
    [locations addObject:currentLocation];
    [locations addObject:bin];
    
    [[BWRoute sharedInstance] fetchRoute:locations travelMode:TravelModeDriving];
}

-(void) drawRouteSelectedBins
{
    if(selectedLocations.count <= 0)
    {
        [self refreshMap];
        [BWLogger DoLog:@"No bins are selected"];
        [BWHelpers displayHud:kNoSelectedBins onView:self.navigationController.view];
        return;
    }

    CLLocation *currentLocation = [[BWDataHandler sharedHandler] getMyLocation];
    if(currentLocation.coordinate.longitude == 0 || currentLocation.coordinate.latitude == 0)
    {
        [self refreshMap];
        [BWLogger DoLog:@"Couldnt retrieve current location"];
        [BWHelpers displayHud:kCurrentLocationFailed onView:self.navigationController.view];
        return;
    }
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    
    // Adding current locations
    [locations addObject:currentLocation];
    
    for(int iter = 0; iter < selectedLocations.count; iter++)
    {
        [locations addObject:[selectedLocations objectAtIndex:iter]];
    }
    [[BWRoute sharedInstance] fetchRoute:locations travelMode:TravelModeDriving];
}

-(void) drawRouteAllReds
{
    CLLocation *currentLocation = [[BWDataHandler sharedHandler] getMyLocation];
    if(currentLocation.coordinate.longitude == 0 || currentLocation.coordinate.latitude == 0)
    {
        [self refreshMap];
        [BWLogger DoLog:@"Couldnt retrieve current location"];
        [BWHelpers displayHud:kCurrentLocationFailed onView:self.navigationController.view];
        return;
    }

    NSMutableArray *locations = [[NSMutableArray alloc] init];

    // Adding current locations
    [locations addObject:currentLocation];
    NSMutableArray *bins = [[[BWDataHandler sharedHandler] fetchBins] mutableCopy];

    for(int iter = 0; iter < bins.count; iter++)
    {
        BWBin *bin = [bins objectAtIndex:iter];
        if(bin.fill.floatValue > RED_BOUNDARY)
            [locations addObject:[[CLLocation alloc] initWithLatitude:bin.latitude.floatValue longitude:bin.longitude.floatValue]];
    }
    [[BWRoute sharedInstance] fetchRoute:locations travelMode:TravelModeDriving];
}

-(void) drawRouteRedYellow
{
    CLLocation *currentLocation = [[BWDataHandler sharedHandler] getMyLocation];
    if(currentLocation.coordinate.longitude == 0 || currentLocation.coordinate.latitude == 0)
    {
        [self refreshMap];
        [BWLogger DoLog:@"Couldnt retrieve current location"];
        [BWHelpers displayHud:kCurrentLocationFailed onView:self.navigationController.view];
        return;
    }
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    
    // Adding current locations
    [locations addObject:currentLocation];
    NSMutableArray *bins = [[[BWDataHandler sharedHandler] fetchBins] mutableCopy];
    
    for(int iter = 0; iter < bins.count; iter++)
    {
        BWBin *bin = [bins objectAtIndex:iter];
        if(bin.fill.floatValue > YELLOW_BOUNDARY)
            [locations addObject:[[CLLocation alloc] initWithLatitude:bin.latitude.floatValue longitude:bin.longitude.floatValue]];
    }
    [[BWRoute sharedInstance] fetchRoute:locations travelMode:TravelModeDriving];
}


-(void) drawBins
{
  NSMutableArray *bins =
      [[[BWDataHandler sharedHandler] fetchBins] mutableCopy];
  int noOfBins = (int)(bins.count);
  runOnMainThread(^{
    for (int iter = 0; iter < noOfBins; iter++) {
      BWBin *bin = [bins objectAtIndex:iter];
      GMSMarker *marker = [[GMSMarker alloc] init];
      marker.position = CLLocationCoordinate2DMake(bin.latitude.floatValue,
                                                   bin.longitude.floatValue);
      marker.appearAnimation = kGMSMarkerAnimationPop;
      marker.title = bin.place;

      NSDictionary *binData = [self getIconAndDataFor:bin];
      marker.icon = [binData objectForKey:kIcon];
      marker.userData = [binData objectForKey:kUserData];
      marker.map = activeMapView;

      NSMutableArray *arr = [[NSMutableArray alloc] init];
      [arr addObject:bin];
      [arr addObject:marker];

      [mapMarkers setValue:arr forKey:bin.binID];
    }

  });
    //[self drawRoute];
}

-(void) resetBinIcons
{
    NSArray *allKeys = [mapMarkers allKeys];
    for(NSString *uniqueId in allKeys)
    {
        NSArray *item = [mapMarkers objectForKey:uniqueId];
        BWBin *obj = item[0];
        GMSMarker *marker = item[1];
        marker.icon = [self getIconFor:obj.color];
    }
}

-(NSDictionary *) getIconAndDataFor:(BWBin *) bin
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSInteger binColor = [bin.color integerValue];

    switch(binColor)
    {
        case BWYellow:
            [dict setValue:[UIImage imageNamed:kTrashYellow] forKey:kIcon];
            [dict setValue:kYellow forKey:kUserData];
            return dict;

        case BWRed:
            [dict setValue:[UIImage imageNamed:kTrashRed] forKey:kIcon];
            [dict setValue:kRed forKey:kUserData];
            return dict;

        case BWGreen:
            [dict setValue:[UIImage imageNamed:kTrashGreen] forKey:kIcon];
            [dict setValue:kGreen forKey:kUserData];
            return dict;

        default:
            // TODO:
            return nil;
    }
}

-(UIImage *) getIconFor:(NSNumber *) binC
{
    NSInteger binColor = [binC integerValue];
    switch(binColor)
    {
        case BWYellow:
            return [UIImage imageNamed:@"trashYellow"];
        case BWRed:
            return [UIImage imageNamed:@"trashRed"];
        case BWGreen:
            return [UIImage imageNamed:@"trashGreen"];
        default:
            // TODO:
            return nil;
    }
}

-(void)fetchDataForLocation:(CLLocation *)location withAddress:(NSString *)address
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [BWHelpers displayHud:@"Loading..." onView:self.navigationController.view];
    });
    BWConnectionHandler *connectionHandler = [BWConnectionHandler sharedInstance];
    [connectionHandler getBinsAtPlace:location withAddress:address
                WithCompletionHandler:^(NSArray *bins, NSError *error) {
                    if (!error) {
                        NSLog(@"*********Bins: %@", [bins description]);
                        [self refreshMap];
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
    [self refreshMap];
}

#pragma mark - Notifications
- (void)binDataChanged:(NSNotification *)notification
{
    [self refreshMap];
}

#pragma mark - GMSMapViewDelegates
- (void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self.settingsControl hideControl];
    NSLog(@"did tap at cordinate");
    if(!isMapEdited)
        return;

    //[self resetBinIcons];
    [selectedLocations removeAllObjects];
    [self refreshMap];
    isMapEdited = NO;
}

/*
 Returns:
 YES if this delegate handled the tap event, which prevents the map from performing its default selection behavior, and NO if the map should continue with its default selection behavior.
 */
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    [self.settingsControl hideControl];

    isMapEdited = YES;
    NSLog(@"did tap at marker - %f %f - %@", marker.position.latitude, marker.position.longitude, marker.title);

    if([marker.userData isEqualToString:kYellow])
        marker.icon = [UIImage imageNamed:kTrashPickerYellow];
    else if([marker.userData isEqualToString:kGreen])
        marker.icon = [UIImage imageNamed:kTrashPickerGreen];
    else if([marker.userData isEqualToString:kRed])
        marker.icon = [UIImage imageNamed:kTrashPickerRed];
    
    [selectedLocations addObject:[[CLLocation alloc] initWithLatitude:marker.position.latitude longitude:marker.position.longitude]];
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchResultPlaces count];
}

- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath {
    return searchResultPlaces[indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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

#pragma mark - UITableViewDelegate

- (void)recenterMapToPlacemark:(CLLocation *)placemark {
    
    GMSCameraPosition *newPosition = [GMSCameraPosition cameraWithLatitude:placemark.coordinate.latitude
                                                                 longitude:placemark.coordinate.longitude
                                                                      zoom:zoomLevel];
    [activeMapView animateToCameraPosition:newPosition];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0)
    {
        [self fetchDataForLocation:[BWDataHandler sharedHandler].myLocation withAddress:[BWDataHandler sharedHandler].myLocationAddress];
        [self recenterMapToPlacemark:[BWDataHandler sharedHandler].myLocation];
        // ref: https://github.com/chenyuan/SPGooglePlacesAutocomplete/issues/10
        [self.searchDisplayController setActive:NO];
        [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else
    {
    SPGooglePlacesAutocompletePlace *place = [self placeAtIndexPath:indexPath];
    [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
        if (error) {
            [BWLogger DoLog:@"Could not map selected Place"];
            [BWHelpers displayHud:kSelectedPlaceFetchFailed onView:self.navigationController.view];
        }
        else if (placemark)
        {
            [self fetchDataForLocation:placemark.location withAddress:addressString];
            [self recenterMapToPlacemark:placemark.location];
            // ref: https://github.com/chenyuan/SPGooglePlacesAutocomplete/issues/10
            [self.searchDisplayController setActive:NO];
            [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }];
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

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    searchOn = YES;
    [self resizeMapView];
}

-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    searchOn = NO;
    [self resizeMapView];
}

- (void)deviceOrientationDidChangeNotification:(NSNotification*)note
{
    [self resizeMapView];
}

#pragma mark - RouteFetchDelegate

- (void)routeFetchFailedWithError:(NSError *)error
{
    [BWLogger DoLog:@"Route Fetch failed"];
    [BWHelpers displayHud:kRouteFetchFailed onView:self.navigationController.view];
}

- (void)routeFetchDidReceiveResponse:(NSString *)points
{
    GMSPath *path = [GMSPath pathFromEncodedPath:points];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeWidth = 5.f;
    polyline.strokeColor = [UIColor blackColor];
    polyline.map = activeMapView;
    isMapEdited = YES;
}

#pragma mark - BWSettingsControlDelegate

- (void)didTapSettingsRowWithText:(NSString *)text
{
    if ([text isEqualToString:kRouteToRed]) {
        [self drawRouteAllReds];
    }
    else if ([text isEqualToString:kRouteToRedYellow]){
        [self drawRouteRedYellow];
    }
    else if ([text isEqualToString:kRouteToSelected]){
        [self drawRouteSelectedBins];
    }
    else if ([text isEqualToString:kRouteToNearest]){
        [self drawRouteToNearestBin];
    }
}

@end
