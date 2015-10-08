//
//  BWRoute.h
//  BinWatch
//
//  Created by Seema Kadavan on 9/20/15.
//  Copyright (c) 2015 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BWRoute;
typedef enum tagTravelMode
{
    TravelModeDriving,
    TravelModeBicycling,
    TravelModeTransit,
    TravelModeWalking
}TravelMode;

@protocol BWRouteDelegate <NSObject>

- (void)routeFetchFailedWithError:(NSError *)error;

- (void)routeFetchDidReceiveResponse:(NSString *)points;

@end
@interface BWRoute : NSObject
@property (nonatomic, assign) id<BWRouteDelegate> delegate;

+ (BWRoute *)sharedInstance;
- (void)fetchRoute:(NSArray *)locations travelMode:(TravelMode)travelMode;
@end
