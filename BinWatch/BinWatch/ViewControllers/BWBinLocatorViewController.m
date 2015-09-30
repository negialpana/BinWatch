//
//  BWBinLocatorViewController.m
//  BinWatch
//
//  Created by Supritha Nagesha on 03/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWBinLocatorViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "BWBinCollection.h"

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
    
    // Bangalore MG Road
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:12.9898231
                                                            longitude:77.7148933
                                                                 zoom:zoomLevel];
    
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
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
    
    self.view = mapView;
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
    self.view = mapView;
    
    
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

@end
