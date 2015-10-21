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

// UserDefaults
static NSString* const kCoverageRadius = @"Radius";
static NSString* const kSupportMailID = @"MailID";
static NSString* const kExportPDFOn = @"PDF";
static NSString* const kExportExcelOn = @"EXCEL";
static NSString* const kExportCSVOn = @"CSV";

@interface BWDataHandler ()

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

@end

@implementation BWDataHandler

+ (instancetype)sharedHandler{
    
    static BWDataHandler *sharedHandler = nil;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        sharedHandler = [[BWDataHandler alloc] init];
    });
    return sharedHandler;
}

- (void)insertBins:(NSArray *)bins{
    
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
        bin.fill = [formatter numberFromString:[obj valueForKey:kBinFillPercentage]];
        bin.latitude = [obj valueForKey:kBinLatitude];
        bin.longitude = [obj valueForKey:kBinLongitude];
        bin.place = [obj valueForKey:kBinPlace];
        bin.area = [[obj valueForKey:kAddress] valueForKey:kArea];
        bin.city = [[obj valueForKey:kAddress] valueForKey:kCity];
        

        // UTC is in milliseconds. Converting to seconds
        NSNumber *dateInSeconds = [obj valueForKey:kBinDate];
        dateInSeconds = @([dateInSeconds floatValue] / 1000);
        bin.date = [NSDate dateWithTimeIntervalSince1970:[dateInSeconds floatValue]];

        // TODO: Hard coded
        int abc = [BWHelpers colorForPercent:[[obj valueForKey:kBinFillPercentage] floatValue]];
        NSNumber *numInt = [NSNumber numberWithInt:abc];
        bin.color = numInt;
        //bin.color = [BWHelpers colorForPercentTemp:[[obj valueForKey:kBinFillPercentage] floatValue]];
    }
    
    NSError *error= nil;
    if (![context save:&error]) {
        NSLog(@"Could not save the bins to Application Database");
    }
    
}

- (NSArray *)fetchBins{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntity inManagedObjectContext:context];
    [request setEntity:entity];
    NSError *error = nil;
    
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if(error || objects.count == 0)
        return nil;
    
//    for (BWBin *object in objects)
//    {
//        NSLog(@"%@", object.binID);
//    }
//    NSLog(@"---------------------------------");
//    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
//    f.numberStyle = NSNumberFormatterDecimalStyle;
//
//    //NSNumber *myNumber = [f numberFromString:@"42"];
//
//    NSMutableArray *bins = [[NSMutableArray alloc] init];
//    //for(int i = 0; i < objects.count; i++)
//    for (id object in objects)
//    {
//        BWBin *bin = [[BWBin alloc] init];
//        bin.binID = [object valueForKey:@"binID"];
//        bin.isAcive = [[object valueForKey:@"isAcive"] boolValue];
//        bin.temperature = [object valueForKey:@"temperature"];
//        bin.humidity = [object valueForKey:@"humidity"];
//        bin.date = [object valueForKey:@"date"];
//        bin.latitude = [object valueForKey:@"latitude"];
//        bin.latitude = [object valueForKey:@"longitude"];
//        //bin.latitude = [NSNumber numberWithFloat:[[object valueForKey:@"latitude"] floatValue]];
////        bin.latitude = [f numberFromString:[object valueForKey:@"latitude"]];
////        bin.latitude = [f numberFromString:[object valueForKey:@"longitude"]];
//        //bin.longitude = [[object valueForKey:@"longitude"] floatValue];
//        bin.color = [[object valueForKey:@"color"] integerValue];
//        bin.place = [object valueForKey:@"place"];
//        bin.fill = [object valueForKey:@"fill"];
//        //bin.fill = [f numberFromString:[object valueForKey:@"fill"]];
//        
//        [bins addObject:bin];
//    }

    // Returning sorted array of objects, based on fill %
    NSSortDescriptor *fillSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kBinFillPercentage ascending:NO];
    NSArray *sortedArray = [objects sortedArrayUsingDescriptors:@[fillSortDescriptor]];
    return sortedArray;
}

-(void) saveSupportMailID:(NSString *)mailID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:mailID forKey:kSupportMailID];
}

-(NSString *) getSupportMailID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:kSupportMailID];
}

-(void) saveCoverageRadius:(int)radius
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithInt:radius] forKey:kCoverageRadius];
}

-(int) getCoverageRadius
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults valueForKey:kCoverageRadius] integerValue];
}

-(void) saveExportPDF:(bool)enable
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithBool:enable] forKey:kExportPDFOn];
}

-(bool) getExportPDF
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults valueForKey:kExportPDFOn] boolValue];
}

-(void) saveExportExcel:(bool)enable
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithBool:enable] forKey:kExportExcelOn];
}

-(bool) getExportExcel
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults valueForKey:kExportExcelOn] boolValue];
}

-(void) saveExportCSV:(bool)enable
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithBool:enable] forKey:kExportCSVOn];
}

-(bool) getExportCSV
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults valueForKey:kExportCSVOn] boolValue];
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

@end
