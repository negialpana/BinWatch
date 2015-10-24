//
//  AppDelegate.h
//  BinWatch
//
//  Created by Supritha Nagesha on 03/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "BWGeocoder.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, BWGeocoderDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *mainTBC;
@property (strong, nonatomic) UITabBarController *userTBC;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic, retain) GMSMapView *mapView;

- (BOOL)connected;
+ (AppDelegate *)appDel;

-(void)switchToMainStoryBoard;
-(void)switchToUserModeStoryBoard;

@end

