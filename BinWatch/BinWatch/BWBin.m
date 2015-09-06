//
//  BWBin.m
//  GHCI Trials
//
//  Created by Seema Kadavan on 9/5/15.
//  Copyright (c) 2015 AirWatch. All rights reserved.
//

#import "BWBin.h"

@implementation BWBin

@synthesize latitude;
@synthesize longitude;
@synthesize color;
@synthesize fillPercent;

- (id) initWith:(CLLocationDegrees)lat
      longitude:(CLLocationDegrees)lon
       binColor:(BWBinColor)binColor
    fillPercent:(float)fill

{
    if (self = [super init])
    {
        self.latitude = lat;
        self.longitude = lon;
        self.color = binColor;
        self.fillPercent = fill;
    }
    
    return self;

}


@end
