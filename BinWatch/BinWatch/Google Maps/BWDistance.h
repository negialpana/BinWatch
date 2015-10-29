//
//  BWDistance.h
//  BinWatch
//
//  Created by Seema Kadavan on 10/29/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface BWDistance : NSObject

+ (BWDistance *)sharedInstance;
- (void)getDistancefrom:(CLLocation *)fromLoc
                     to:(CLLocation *)toLoc
     andCompletionBlock:(void(^)(NSNumber *, CLLocation *,NSError *))completionBlock;

@end
