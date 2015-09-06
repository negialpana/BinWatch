//
//  BWBin.h
//  GHCI Trials
//
//  Created by Seema Kadavan on 9/5/15.
//  Copyright (c) 2015 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>

#import "BWCommon.h"

@interface BWBin : NSObject

@property (atomic, assign) CLLocationDegrees latitude;
@property (atomic, assign) CLLocationDegrees longitude;
@property (atomic, assign) BWBinColor color;
@property float fillPercent;

- (id) initWith:(CLLocationDegrees)lat
      longitude:(CLLocationDegrees)lon
       binColor:(BWBinColor)binColor
    fillPercent:(float)fillPercent;

@end
