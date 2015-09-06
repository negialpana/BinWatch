//
//  DataHandler.m
//  BinWatch
//
//  Created by Supritha Nagesha on 05/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "DataHandler.h"
#import "Bin.h"

@interface DataHandler ()

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;


@end

@implementation DataHandler

+ (instancetype)sharedHandler{
    
    static DataHandler *sharedHandler = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
       
        sharedHandler = [[DataHandler alloc] init];
    });
    return sharedHandler;
}

- (void)insertBins:(NSArray *)bins{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for(NSDictionary *obj in bins){
        
        Bin *bin = [NSEntityDescription insertNewObjectForEntityForName:@"Bin"
                                                 inManagedObjectContext:context];
        bin.id = [obj valueForKey:@"_id"];
        bin.isAcive = [[obj valueForKey:@"isActive"] boolValue];
        bin.temperature = [obj valueForKey:@"temperature"];
        bin.humidity = [obj valueForKey:@"humidity"];
       // bin.date = [obj valueForKey:@"date"];
        bin.latutude = [obj valueForKey:@"latitude"];
        bin.longitude = [obj valueForKey:@"longitude"];
        bin.bincolor = [obj valueForKey:@"binColor"];
        
    }
    
    NSError *error= nil;
    if (![context save:&error]) {
        NSLog(@"Could not save the bins to Application Database");
    }
    
}

- (NSArray *)fetchBins{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Bin" inManagedObjectContext:context];
    [request setEntity:entity];
    NSError *error = nil;
    
    NSArray *bins = [context executeFetchRequest:request error:&error];
    
    return error?nil:bins;
}

#pragma CoreData Stack

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
 Returns the URL to the application's documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
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
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BinWatch.sqlite"];
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
