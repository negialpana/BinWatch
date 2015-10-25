//
//  AppDelegate.m
//  BinWatch
//
//  Created by Supritha Nagesha on 03/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "AppDelegate.h"
#import "BWConstants.h"
#import "BWAppSettings.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Reachability.h"
#import "BWDataHandler.h"
#import "BWGeocoder.h"
#import "BWConnectionHandler.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    BOOL firstLocationUpdate;
}

@synthesize mapView = _mapView;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Life Cycle Methods
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    firstLocationUpdate = NO;
    [[BWGeocoder sharedInstance] setDelegate:self];

    [self setTheStoryBoards];
    [self switchToMainStoryBoard];
    
    [Fabric with:@[[Crashlytics class]]];
    [GMSServices provideAPIKey:kGoogleAPIKey];
    
    [self startReachabilityNotifier];
    [self initMaps];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (![self connected]) {
        SHOWALERT(kNotConnectedTitle, kNotConnectedText);
    }

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [_mapView removeObserver:self
                 forKeyPath:@"myLocation"
                    context:NULL];

}

#pragma mark - Utility Methods
+ (AppDelegate *)appDel
{
    AppDelegate *theDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return theDelegate;
}
-(UIViewController *)getTabBarContoller
{
    return self.window.rootViewController;
}
- (void)setTheStoryBoards {
    
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIStoryboard *userModeSB = [UIStoryboard storyboardWithName:@"UserMode" bundle:[NSBundle mainBundle]];
    UITabBarController *mainTBC = [mainSB instantiateInitialViewController];
    UITabBarController *userTBC = [userModeSB instantiateInitialViewController];
    self.mainTBC = mainTBC;
    self.userTBC = userTBC;
}

-(void)switchToMainStoryBoard
{
    self.window.rootViewController = self.mainTBC;
    [[BWAppSettings sharedInstance] saveAppMode:BWBBMPMode];
}

-(void)switchToUserModeStoryBoard
{
    self.window.rootViewController = self.userTBC;
    [[BWAppSettings sharedInstance] saveAppMode:BWUserMode];
}

- (void)startReachabilityNotifier
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kReachabilityChangedNotification object:nil];
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

-(void) initMaps
{
    _mapView = [GMSMapView mapWithFrame:CGRectMake(0,0,0,0) camera:nil];
    _mapView.settings.myLocationButton = YES;
    [_mapView addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        _mapView.myLocationEnabled = YES;
    });
}

#pragma mark - KVO updates
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    CLLocation *currentLocation = [change objectForKey:NSKeyValueChangeNewKey];
    NSString *infoMsg = [NSString stringWithFormat:@"Location Update %f %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
    [BWLogger DoLog:infoMsg];
    [[BWGeocoder sharedInstance] reverseGeocode:currentLocation];
}

#pragma mark - BWGeocoderDelegate

- (void)geocoderDidReceiveResponse:(NSString *)address forLocation:(CLLocation *)location
{
    [BWDataHandler sharedHandler].myLocationAddress = address;
    [BWDataHandler sharedHandler].myLocation = location;
    
    if (!firstLocationUpdate)
    {
        firstLocationUpdate = YES;
        NSString *infoMsg = [NSString stringWithFormat:@"First Location Update %@ %f %f", address, location.coordinate.latitude, location.coordinate.longitude];
        [BWLogger DoLog:infoMsg];
        BWConnectionHandler *connectionHandler = [BWConnectionHandler sharedInstance];
        [connectionHandler getBinsAtPlace:location withAddress:address
                    WithCompletionHandler:^(NSArray *bins, NSError *error) {
                        if (!error) {
                            // Do Nothing
                        }
                        else
                        {
                            // retry? No. Let user search.
                        }
                    }];
    }

}

#pragma mark - Notification
- (void)networkChanged:(NSNotification *)notification
{
    if ([self connected]) {
        SHOWALERT(kConnectedTitle, kConnectedText);
    }
    else{
        SHOWALERT(kNotConnectedTitle, kNotConnectedText);
    }
}

// TODO: Do we need CoreData code here?
#pragma mark - Core Data

- (void)saveContext{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BinDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BinDataModel.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
