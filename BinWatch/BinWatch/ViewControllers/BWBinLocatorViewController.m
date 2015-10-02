//
//  BWBinLocatorViewController.m
//  BinWatch
//
//  Created by Supritha Nagesha on 03/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWBinLocatorViewController.h"
#import "BWBinCollection.h"
#import "SPGooglePlacesAutocomplete.h"


@interface BWBinLocatorViewController () <GMSMapViewDelegate>

@end

@implementation BWBinLocatorViewController
{
    GMSMapView *mapView;
    BOOL firstLocationUpdate_;
    float zoomLevel;
    NSMutableDictionary *mapMarkers;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Debug Code
    [self initBins];
    // Do any additional setup after loading the view.
    zoomLevel = 15;
    mapMarkers = [[NSMutableDictionary alloc] init];
    firstLocationUpdate_ = NO;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceOrientationDidChangeNotification:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];

    
    searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:kGoogleAPIKey_Browser];
    shouldBeginEditing = YES;
    self.searchDisplayController.searchBar.placeholder = @"Search Locations";

    
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:12.9898231
//                                                            longitude:77.7148933
//                                                                 zoom:zoomLevel];
    
    // Bangalore MG Road
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:12.9667
                                                            longitude:77.5667
                                                                 zoom:zoomLevel];
    //mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];

    NSLog(@"%f %f %f %f", self.view.frame.size.height, self.view.frame.size.width, self.view.frame.origin.x, self.view.frame.origin.y);

    mapView = [GMSMapView mapWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height) camera:camera];
    mapView.delegate = self;
    [self drawBins];
    
    mapView.settings.myLocationButton = YES;
    
    [mapView addObserver:self
              forKeyPath:@"myLocation"
                 options:NSKeyValueObservingOptionNew
                 context:NULL];
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView.myLocationEnabled = YES;
    });
    
//    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 20, 320, 60)];
//    //UISearchBar *searchBar = [[UISearchBar alloc] init];
//    searchBar.delegate = self;
//    //searchBar.showsCancelButton = YES;
//    searchBar.placeholder = @"Search Maps";
//
//    [self.view addSubview:searchBar];
    //self.view = mapView;
    [self.view addSubview:mapView];
    
    // TODO: Refactor this
    NSArray *subViews = [self.view subviews];
    UIView *searchBar = [subViews objectAtIndex:0];
    [self.view bringSubviewToFront:searchBar];
//    for(int i = 0; i < subViews.count; i++)
//    {
//        UIView* view =subViews[i];
//        NSLog(@"%f", view.layer.zPosition);
//    }
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

#pragma mark - Map Utils
// TODO: Debug method - To be removed
- (void) initBins
{
    BWBin *bin1 = [[BWBin alloc] initWith:12.9667 longitude:77.5667 binID:@"1" binColor:BWRed place:@"Bangalore"];
    BWBin *binGS = [[BWBin alloc] initWith:12.9898231 longitude:77.7148933 binID:@"2" binColor:BWYellow place:@"Hoodi-GS"];
    BWBin *binHoodiCircle = [[BWBin alloc] initWith:12.9922204 longitude:77.7159097 binID:@"3" binColor:BWGreen place:@"Hoodi-Circle"];
    BWBin *binGG = [[BWBin alloc] initWith:12.9907939 longitude:77.7158042 binID:@"4" binColor:BWRed place:@"Hoodi-GG"];
    BWBin *binMetropolis = [[BWBin alloc] initWith:12.9900505 longitude:77.7029976 binID:@"5" binColor:BWRed place:@"Hoodi-Metropolis"];
    
    BWBin *binPhoenix = [[BWBin alloc] initWith:12.9969527 longitude:77.696218 binID:@"6" binColor:BWRed place:@"Hoodi-Phoenix"];
    
    BWBin *binQCinemas = [[BWBin alloc] initWith:12.9869799 longitude:77.7359825 binID:@"7" binColor:BWGreen place:@"Hoodi-QCinemas"];
    
    BWBin *binShantiniketan = [[BWBin alloc] initWith:12.9940831 longitude:77.7308743 binID:@"8" binColor:BWYellow place:@"Hoodi-Shantiniketan"];
    
    
    [[BWBinCollection sharedInstance] addBin:bin1];
    [[BWBinCollection sharedInstance] addBin:binGS];
    [[BWBinCollection sharedInstance] addBin:binHoodiCircle];
    [[BWBinCollection sharedInstance] addBin:binGG];
    [[BWBinCollection sharedInstance] addBin:binMetropolis];
    [[BWBinCollection sharedInstance] addBin:binPhoenix];
    [[BWBinCollection sharedInstance] addBin:binQCinemas];
    [[BWBinCollection sharedInstance] addBin:binShantiniketan];

}

-(void) drawBins
{
    //return;
    NSMutableArray *bins = [[BWBinCollection sharedInstance] bins];
    int noOfBins = bins.count;
    
    for(int iter = 0; iter < noOfBins; iter++)
    {
        BWBin *bin = [bins objectAtIndex:iter];
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(bin.latitude, bin.longitude);
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
    //self.view = mapView;
    //[self drawRoute];
}

-(void) drawRoute
{
    // TODO: Test Code
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    
    [locations addObject:[[CLLocation alloc] initWithLatitude:12.989823 longitude:77.714893]];
    [locations addObject:[[CLLocation alloc] initWithLatitude:12.996953 longitude:77.69621]];
    [locations addObject:[[CLLocation alloc] initWithLatitude:12.9869799 longitude:77.7359825]];
    
    //[[BWRoute sharedInstance] fetchRoute:locations travelMode:TravelModeDriving];
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

-(UIImage *) getIconFor:(BWBinColor) binColor
{
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
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                        zoom:zoomLevel];
    }
}

#pragma mark - GMSMapViewDelegates
- (void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"did tap at cordinate");
    [self resetBinIcons];
}

/*
 Returns:
 YES if this delegate handled the tap event, which prevents the map from performing its default selection behavior, and NO if the map should continue with its default selection behavior.
 */
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    NSLog(@"did tap at marker - %f %f - %@", marker.position.latitude, marker.position.longitude, marker.title);
    marker.icon = [UIImage imageNamed:@"trashSelected"];
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

//- (void)recenterMapToPlacemark:(CLPlacemark *)placemark {
//    MKCoordinateRegion region;
//    MKCoordinateSpan span;
//
//    span.latitudeDelta = 0.02;
//    span.longitudeDelta = 0.02;
//
//    region.span = span;
//    region.center = placemark.location.coordinate;
//
//    [self.mapView setRegion:region];
//}

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
            //[self recenterMapToPlacemark:placemark];
            // ref: https://github.com/chenyuan/SPGooglePlacesAutocomplete/issues/10
            [self.searchDisplayController setActive:NO];
            [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }];
}

#pragma mark -
#pragma mark UISearchDisplayDelegate

- (void)handleSearchForSearchString:(NSString *)searchString {
    //searchQuery.location = self.mapView.userLocation.coordinate;
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

#pragma mark -
#pragma mark UISearchBar Delegate

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
    [mapView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
}
@end
