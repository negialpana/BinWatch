//
//  BWDataHandler.h
//  BinWatch
//
//  Created by Supritha Nagesha on 05/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CoreLocation/CLLocation.h"

typedef NS_ENUM(NSUInteger, BWAppMode) {
    BWBBMPMode,
    BWUserMode,
};

@interface BWDataHandler : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, getter = getMyLocation) CLLocation *myLocation;
@property (nonatomic, retain) NSString *myLocationAddress;
@property (nonatomic, retain, getter = getBinsLocation) CLLocation *binsLocation;
@property (nonatomic, retain, getter = getBinsAddress) NSString *binsAddress;

+ (instancetype) sharedHandler;

- (void) insertBins:(NSArray *)bins forLocation:(CLLocation *)location withAddress:(NSString *)address;
- (NSArray *) fetchBins;

@end
