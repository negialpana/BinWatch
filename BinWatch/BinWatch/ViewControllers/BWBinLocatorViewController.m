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
#import "BWCommon.h"

#define DEFAULT_ZOOM_LEVEL 15
@interface BWBinLocatorViewController () <GMSMapViewDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *mapSearchBar;

@end

@implementation BWBinLocatorViewController
{
    GMSMapView *mapView;
    BOOL firstLocationUpdate_;
    float zoomLevel;
    NSMutableDictionary *mapMarkers;
    CLLocation *currentLocation;
    NSMutableArray *selectedLocations;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    zoomLevel = DEFAULT_ZOOM_LEVEL;

    mapMarkers = [[NSMutableDictionary alloc] init];
    currentLocation = [[CLLocation alloc] init];
    selectedLocations = [[NSMutableArray alloc] init];

    firstLocationUpdate_ = NO;
    [[BWRoute sharedInstance] setDelegate:self];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceOrientationDidChangeNotification:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    
    searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:kGoogleAPIKey_Browser];
    shouldBeginEditing = YES;
    self.searchDisplayController.searchBar.placeholder = @"Search Locations";

    // Bangalore MG Road
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:12.9667
                                                            longitude:77.5667
                                                                 zoom:zoomLevel];

    mapView = [GMSMapView mapWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height) camera:camera];
    // TODO: Give an option for hybrid view
    //mapView.mapType = kGMSTypeHybrid;
    [self resizeMapView];
    mapView.delegate = self;

    [self drawBins];
    
    mapView.settings.myLocationButton = YES;
    mapView.trafficEnabled = YES;
    mapView.buildingsEnabled = YES;
    // TODO: Does this help?
    //mapView.indoorEnabled = YES;
    [mapView addObserver:self
              forKeyPath:@"myLocation"
                 options:NSKeyValueObservingOptionNew
                 context:NULL];
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView.myLocationEnabled = YES;
    });
    
    [self.mapSearchBar setBackgroundImage:[[UIImage alloc]init]];
    [self.mapSearchBar setTranslucent:NO];
//    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:14.0/255.0 green:114.0/255.0 blue:199.0/255.0 alpha:1]];
    
//    UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.mapSearchBar];
//    self.navigationItem.rightBarButtonItem = searchBarItem;
    
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"more_dashes"] style:UIBarButtonItemStyleDone target:self action:@selector(moreTapped)];
    self.navigationItem.rightBarButtonItem = moreButton;

//    UIButton* myLocationButton = (UIButton*)[[mapView subviews] lastObject];
//    myLocationButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
//    CGRect frame = myLocationButton.frame;
//    frame.origin.x = 5;
//    myLocationButton.frame = frame;
    
    [self.view addSubview:mapView];
    [self.view bringSubviewToFront:_mapSearchBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [mapView removeObserver:self
                 forKeyPath:@"myLocation"
                    context:NULL];
}

#pragma mark - Event Handlers
- (void)moreTapped
{
    NSLog(@"More tapped");
    [self drawRouteSelectedBins];
}

#pragma mark - Map Utils
- (void) resizeMapView
{
    [mapView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height)];
}

-(void) flushAllRoutes
{
    [mapView clear];
    [self drawBins];
}

-(void) drawRouteSelectedBins
{
    // TODO: Hardcoded for testing
    currentLocation = [[CLLocation alloc] initWithLatitude:12.927991 longitude:77.60381700000001];
    if(currentLocation.coordinate.longitude == 0 || currentLocation.coordinate.latitude == 0)
    {
        NSLog(@"Couldnt retrieve current location");
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
    // TODO: Hardcoded for testing
    currentLocation = [[CLLocation alloc] initWithLatitude:12.927991 longitude:77.60381700000001];
    if(currentLocation.coordinate.longitude == 0 || currentLocation.coordinate.latitude == 0)
    {
        NSLog(@"Couldnt retrieve current location");
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
    currentLocation = [[CLLocation alloc] initWithLatitude:12.927991 longitude:77.60381700000001];
    if(currentLocation.coordinate.longitude == 0 || currentLocation.coordinate.latitude == 0)
    {
        NSLog(@"Couldnt retrieve current location");
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
    NSMutableArray *bins = [[[BWDataHandler sharedHandler] fetchBins] mutableCopy];
    int noOfBins = bins.count;
    
    for(int iter = 0; iter < noOfBins; iter++)
    {
        BWBin *bin = [bins objectAtIndex:iter];
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(bin.latitude.floatValue, bin.longitude.floatValue);
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.title = bin.place;
        marker.icon = [self getIconFor:bin.color];
        marker.map = mapView;
        
        // TODO: is there a better alternative for this? Objective C equivalent of C struct
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject:bin];
        [arr addObject:marker];
        
        [mapMarkers setValue:arr forKey:bin.binID];
    }
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

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    NSLog(@"Location Update");
    CLLocation *location;
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        location = [change objectForKey:NSKeyValueChangeNewKey];
        mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                        zoom:zoomLevel];
    }
    
    // TODO: Is this the correct place to do this?
    currentLocation = [[CLLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
}

#pragma mark - GMSMapViewDelegates
- (void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"did tap at cordinate");
    [self resetBinIcons];
    [selectedLocations removeAllObjects];
}

/*
 Returns:
 YES if this delegate handled the tap event, which prevents the map from performing its default selection behavior, and NO if the map should continue with its default selection behavior.
 */
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    NSLog(@"did tap at marker - %f %f - %@", marker.position.latitude, marker.position.longitude, marker.title);
    marker.icon = [UIImage imageNamed:@"trashSelected"];
    
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

#pragma mark UITableViewDataSource

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
    
    cell.textLabel.font = [UIFont fontWithName:@"GillSans" size:16.0];
    cell.textLabel.text = [self placeAtIndexPath:indexPath].name;
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)recenterMapToPlacemark:(CLPlacemark *)placemark {
    
    GMSCameraPosition *newPosition = [GMSCameraPosition cameraWithLatitude:placemark.location.coordinate.latitude
                                                            longitude:placemark.location.coordinate.longitude
                                                                 zoom:zoomLevel];
    [mapView animateToCameraPosition:newPosition];
}

//- (void)addPlacemarkAnnotationToMap:(CLPlacemark *)placemark addressString:(NSString *)address {
//    [self.mapView removeAnnotation:selectedPlaceAnnotation];
//
//    selectedPlaceAnnotation = [[MKPointAnnotation alloc] init];
//    selectedPlaceAnnotation.coordinate = placemark.location.coordinate;
//    selectedPlaceAnnotation.title = address;
//    [self.mapView addAnnotation:selectedPlaceAnnotation];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SPGooglePlacesAutocompletePlace *place = [self placeAtIndexPath:indexPath];
    [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not map selected Place"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        } else if (placemark) {
            //[self addPlacemarkAnnotationToMap:placemark addressString:addressString];
            [self recenterMapToPlacemark:placemark];
            // ref: https://github.com/chenyuan/SPGooglePlacesAutocomplete/issues/10
            [self.searchDisplayController setActive:NO];
            [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }];
}

#pragma mark - UISearchDisplayDelegate

- (void)handleSearchForSearchString:(NSString *)searchString {
    //searchQuery.location = self.mapView.userLocation.coordinate;
    // TODO: This has to be corrected
    searchQuery.location = CLLocationCoordinate2DMake(12.9898231, 77.7148933);
    searchQuery.input = searchString;
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not fetch Places"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
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

// TODO: Can I do this using auto resize masks?
- (void)deviceOrientationDidChangeNotification:(NSNotification*)note
{
    [self resizeMapView];
}

#pragma mark - RouteFetchDelegate

- (void)routeFetchFailedWithError:(NSError *)error
{
    NSLog(@"Route Fetch failed");
}


- (void)routeFetchDidReceiveResponse:(NSString *)points
{
    GMSPath *path = [GMSPath pathFromEncodedPath:points];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeWidth = 3.f;
    polyline.strokeColor = [UIColor redColor];
    polyline.map = mapView;
}

@end
