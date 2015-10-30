//
//  BWGeocoder.m
//  BinWatch
//
//  Created by Seema Kadavan on 9/22/15.
//  Copyright (c) 2015 AirWatch. All rights reserved.
//

#import "BWGeocoder.h"

// TODO: why is API key optional?
// TODO: What is static geocoding vs dynamic geocoding?
// https://developers.google.com/maps/documentation/geocoding/intro#ReverseGeocoding
// Endpoint vs reverseGeocodeCoordinate - which is better?
// set optional parameters for reverseGeocodeCoordinate?
// Which is the most efficient way of issueing this request? using available filetrs? is there a way to narrow down the search?
// TODO: Take care of all error messages
// Few filters requires https req

@implementation BWGeocoder

+ (BWGeocoder *)sharedInstance
{
    static dispatch_once_t onceToken;
    static BWGeocoder *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BWGeocoder alloc] init];
    });
    
    return instance;
}

- (void) reverseGeocode:(CLLocation *)location
{
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude) completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
        if(!error)
        {
            GMSAddress* addressObj = [[response results] objectAtIndex:0];
            NSMutableString *address = [[NSMutableString alloc] init];
            for(int i = 0; i < [addressObj lines].count; i++)
            {
                NSString *lines = [[addressObj lines] objectAtIndex:i];
                if(i != 0)
                   [address appendString:@","];
                [address appendString:lines];
            }
            if ([self.delegate respondsToSelector:@selector(geocoderDidReceiveResponse:forLocation:)])
            {
                [self.delegate geocoderDidReceiveResponse:address forLocation:location];
            }
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(geocoderFailedWithError:)])
            {
                [self.delegate geocoderFailedWithError:error];
            }
        }
    }];
    
}

@end
