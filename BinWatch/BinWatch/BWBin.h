//
//  BWBin.h
//  BinWatch
//
//  Created by Seema Kadavan on 9/5/15.
//  Copyright (c) 2015 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>

#import "BWConstants.h"

@interface BWBin : NSObject

@property (atomic, copy) NSString * binID;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber *color;
@property (nonatomic, retain) NSNumber * fill;
@property (nonatomic, retain) NSNumber * temperature;
@property (nonatomic, retain) NSNumber * humidity;
@property (atomic, copy) NSString *place;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, assign) BOOL isAcive;

@end
