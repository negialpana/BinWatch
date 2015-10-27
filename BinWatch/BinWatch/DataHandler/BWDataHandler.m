//
//  BWDataHandler.m
//  BinWatch
//
//  Created by Supritha Nagesha on 05/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWDataHandler.h"
#import "BWBin.h"
#import "BWHelpers.h"

static NSString* const kEntity = @"Bin";

static NSString* const kBinID = @"_id";
static NSString* const kBinIsActive = @"isActive";
static NSString* const kBinTemperature = @"temperature";
static NSString* const kBinHumidity = @"humidity";
static NSString* const kBinDate = @"date";
static NSString* const kBinFillPercentage = @"fill";
static NSString* const kBinLatitude = @"latitude";
static NSString* const kBinLongitude = @"longitude";
static NSString* const kBinPlace = @"name";
static NSString* const kAddress = @"address";
static NSString* const kCity = @"city";
static NSString* const kArea = @"area";
static NSString* const kBinsLatitude = @"BinsLatitude";
static NSString* const kBinsLongitude = @"BinsLongitude";
static NSString* const kBinsAddress = @"BinsAddress";


@interface BWDataHandler () <CLLocationManagerDelegate>

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

@end

@implementation BWDataHandler
{
    NSString *savedBinsLocation;
    CLLocationManager *locationManager;
    CLLocation *locationFromAppKit;
}

@synthesize myLocation;

+ (instancetype)sharedHandler{
    
    static BWDataHandler *sharedHandler = nil;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        sharedHandler = [[BWDataHandler alloc] init];
    });
    return sharedHandler;
}

- (id) init
{
    if (self = [super init])
    {
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
                [locationManager requestWhenInUseAuthorization];
            [locationManager startUpdatingLocation];
    }
    
    return self;
    
}

-(CLLocation *)getMyLocation
{
    if(myLocation)
        return myLocation;
    else
        return locationFromAppKit;
}

-(CLLocation *)getBinsLocation
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[CLLocation alloc] initWithLatitude:[[defaults valueForKey:kBinsLatitude] floatValue] longitude:[[defaults valueForKey:kBinsLongitude] floatValue]];
}

-(NSString *)getBinsAddress
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:kBinsAddress];
}

- (void)insertBins:(NSArray *)bins forLocation:(CLLocation *)location withAddress:(NSString *)address
{
    // Save a fresh data set
    [self flushData];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;

    // Dummy data code
    for(NSDictionary *obj in bins){
        BWBin *bin = [NSEntityDescription insertNewObjectForEntityForName:kEntity
                                                 inManagedObjectContext:context];
        
        bin.binID = [obj valueForKey:kBinID];
        bin.isAcive = [[obj valueForKey:kBinIsActive] boolValue];
        bin.temperature = [obj valueForKey:kBinTemperature];
        bin.humidity = [obj valueForKey:kBinHumidity];
        bin.fill = [obj valueForKey:kBinFillPercentage];
        bin.latitude = [obj valueForKey:kBinLatitude];
        bin.longitude = [obj valueForKey:kBinLongitude];
        bin.place = [obj valueForKey:kBinPlace];
        bin.area = [[obj valueForKey:kAddress] valueForKey:kArea];
        bin.city = [[obj valueForKey:kAddress] valueForKey:kCity];
        
        // UTC is in milliseconds. Converting to seconds
        NSNumber *dateInSeconds = [obj valueForKey:kBinDate];
        dateInSeconds = @([dateInSeconds floatValue] / 1000);
        bin.date = [NSDate dateWithTimeIntervalSince1970:[dateInSeconds floatValue]];

        int abc = [BWHelpers colorForPercent:[[obj valueForKey:kBinFillPercentage] floatValue]];
        NSNumber *numInt = [NSNumber numberWithInt:abc];
        bin.color = numInt;
    }
    
    NSError *error= nil;
    if (![context save:&error])
    {
        [BWLogger DoLog:@"Could not save the bins to Application Database"];
    }
    else
    {
        NSString *errMsg = [NSString stringWithFormat:@"Saving set of bins %f %f %@", location.coordinate.latitude, location.coordinate.longitude, address];
        [BWLogger DoLog:errMsg];

        _binsLocation = location;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:[NSNumber numberWithFloat:location.coordinate.latitude] forKey:kBinsLatitude];
        [defaults setValue:[NSNumber numberWithFloat:location.coordinate.longitude] forKey:kBinsLongitude];
        [defaults setValue:address forKey:kBinsAddress];
        [[NSNotificationCenter defaultCenter] postNotificationName: kBinDataChangedNotification object: nil];
    }
}

- (NSArray *)fetchBins{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setReturnsObjectsAsFaults:NO];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntity inManagedObjectContext:context];
    [request setEntity:entity];
    NSError *error = nil;
    
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if(error || objects.count == 0)
        return nil;

    // Returning sorted array of objects, based on fill %
    NSSortDescriptor *fillSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kBinFillPercentage ascending:NO];
    NSArray *sortedArray = [objects sortedArrayUsingDescriptors:@[fillSortDescriptor]];
    return sortedArray;
}


#pragma mark - Private Methods
- (void) flushData
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntity inManagedObjectContext:context];
    [request setEntity:entity];
    NSError *error = nil;
    
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    //error handling goes here
    for (NSManagedObject *bin in objects) {
        [context deleteObject:bin];
    }
    NSError *saveError = nil;
    [context save:&saveError];
    
    //[self fetchBins];
    // TODO: iOS9+
    //    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Car"];
    //    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    //
    //    NSError *deleteError = nil;
    //    [myPersistentStoreCoordinator executeRequest:delete withContext:myContext error:&deleteError];
}

#pragma mark - CoreData Stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [NSManagedObjectContext new];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BinWatch" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;

}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[BWHelpers applicationDocumentsDirectory] URLByAppendingPathComponent:@"BinWatch.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        [BWLogger DoLog:[NSString stringWithFormat:@"Unresolved error %@, %@", error, [error userInfo]]];

        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - CLLocationManagerDelegate

// This is just a backup. Just in case google maps is not initialised, we can get current location from here
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    locationFromAppKit = newLocation;
}
@end
