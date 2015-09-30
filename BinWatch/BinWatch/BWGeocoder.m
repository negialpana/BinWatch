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

#define kReverseGeocoder @"http://maps.googleapis.com/maps/api/geocode/json?latlng="

// TODO: Take care of parallel requests
@implementation BWGeocoder
{
    NSMutableData *responseData;
}

+ (BWGeocoder *)sharedInstance
{
    static dispatch_once_t onceToken;
    static BWGeocoder *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BWGeocoder alloc] init];
    });
    
    return instance;
}

- (id) init
{
    if (self = [super init])
    {
        responseData = [[NSMutableData alloc] init];
    }
    
    return self;
}

- (void)reverseGeocode:(CLLocationCoordinate2D)location
{
    NSString* url = [NSString stringWithFormat:@"%@%f,%f%@", kReverseGeocoder,location.latitude,location.longitude, @"&language=en"];
    NSURLRequest *_request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    //NSURLRequest *_request = [NSURLRequest requestWithURL:[NSURL URLWithString:hello]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:_request  delegate:self];
}

- (void) reverseGeocoder:(CLLocationCoordinate2D)location
{
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake(location.latitude, location.longitude) completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
        NSLog(@"reverse geocoding results:");
        // TODO: Handle Error
        GMSAddress* addressObj = [[response results] objectAtIndex:0];
        NSMutableString *address = [[NSMutableString alloc] init];
        for(NSString* lines in [addressObj lines])
        {
            [address appendString:lines];
        }
        NSLog(@"ADDRESS: %@", address);
        if ([self.delegate respondsToSelector:@selector(geocoderDidReceiveResponse:)])
        {
            [self.delegate geocoderDidReceiveResponse:address];
        }


//        for(GMSAddress* addressObj in [response results])
//        {
//            NSLog(@"coordinate.latitude=%f", addressObj.coordinate.latitude);
//            NSLog(@"coordinate.longitude=%f", addressObj.coordinate.longitude);
//            NSLog(@"thoroughfare=%@", addressObj.thoroughfare);
//            NSLog(@"locality=%@", addressObj.locality);
//            NSLog(@"subLocality=%@", addressObj.subLocality);
//            NSLog(@"administrativeArea=%@", addressObj.administrativeArea);
//            NSLog(@"postalCode=%@", addressObj.postalCode);
//            NSLog(@"country=%@", addressObj.country);
//            NSLog(@"lines=%@", addressObj.lines);
//        }
        
    }];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse");
    [responseData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //[self.responseData appendData:data];
    [responseData appendData:data];
    NSLog(@"Did receive Data");
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@",[NSString stringWithFormat :@"didfailwitherror: %@", [error description]]);
    
    if ([self.delegate respondsToSelector:@selector(geocoderFailedWithError:)])
    {
        [self.delegate geocoderFailedWithError:error];
    }
}

-(void)connectionDidFinishLoading: (NSURLConnection *)connection{
    NSLog(@"Success Code:");
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    if (!error)
    {
        // Can we use GMSAddress object here
        NSArray *results = [json objectForKey:@"results"];
        NSString *address = [[results objectAtIndex:0] objectForKey:@"formatted_address"];
        NSLog(@"ADDRESS: %@", address);

        // TODO: Handle Error
        if ([self.delegate respondsToSelector:@selector(geocoderDidReceiveResponse:)])
        {
            [self.delegate geocoderDidReceiveResponse:address];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(geocoderFailedWithError:)])
        {
            [self.delegate geocoderFailedWithError:error];
        }
    }
}

@end
