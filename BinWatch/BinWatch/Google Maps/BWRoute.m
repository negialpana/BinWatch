//
//  BWRoute.m
//  BinWatch
//
//  Created by Seema Kadavan on 9/20/15.
//  Copyright (c) 2015 AirWatch. All rights reserved.
//

#import "BWRoute.h"
#import <GoogleMaps/GoogleMaps.h>

#define kDirectionsURL @"http://maps.googleapis.com/maps/api/directions/json?"

// TODO: Take care of parallel requests
@implementation BWRoute
{
    NSMutableData *responseData;
}

+ (BWRoute *)sharedInstance
{
    static dispatch_once_t onceToken;
    static BWRoute *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BWRoute alloc] init];
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

- (void)fetchRoute:(NSArray *)locations travelMode:(TravelMode)travelMode
{
    NSUInteger locationsCount = [locations count];
    
    if (locationsCount < 2) return;
    
    //    if ([_request inProgress])
    //        [_request clearDelegatesAndCancel];
    
    NSMutableArray *locationStrings = [NSMutableArray new];

    for (CLLocation *location in locations)
    {
        [locationStrings addObject:[[NSString alloc] initWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude]];
    }
    
    NSString *sensor = @"false";
    NSString *origin = [locationStrings objectAtIndex:0];
    NSString *destination = [locationStrings lastObject];
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@origin=%@&destination=%@&sensor=%@", kDirectionsURL, origin, destination, sensor];
    

    if (locationsCount > 2)
    {
        [url appendString:@"&waypoints=optimize:true"];
        for (int i = 1; i < [locationStrings count] - 1; i++)
        {
            [url appendFormat:@"|%@", [locationStrings objectAtIndex:i]];
        }
    }

    switch (travelMode)
    {
        case TravelModeWalking:
            [url appendString:@"&mode=walking"];
            break;
        case TravelModeBicycling:
            [url appendString:@"&mode=bicycling"];
            break;
        case TravelModeTransit:
            [url appendString:@"&mode=transit"];
            break;
        default:
            [url appendString:@"&mode=driving"];
            break;
    }

    NSMutableString *urlReq = [NSMutableString stringWithString:[url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    
//    NSMutableString *urlReq = [NSMutableString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=12.989823,77.714893&destination=12.996953,77.696218&sensor=false&mode=driving"];
    
    //    _request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url] usingCache:nil andCachePolicy:ASIDoNotReadFromCacheCachePolicy | ASIDoNotWriteToCacheCachePolicy | ASIDontLoadCachePolicy];
    //
    //    __weak ASIHTTPRequest *weakRequest = _request;
    
    NSURLRequest *_request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlReq]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:_request  delegate:self];
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
    
    if ([self.delegate respondsToSelector:@selector(routeFetchFailedWithError:)])
    {
        [self.delegate routeFetchFailedWithError:error];
    }
}

-(void)connectionDidFinishLoading: (NSURLConnection *)connection{
    NSLog(@"Success Code:");
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    
    if (!error)
    {
        NSArray *routesArray = [json objectForKey:@"routes"];
        
        if ([routesArray count] > 0)
        {
            NSDictionary *routeDict = [routesArray objectAtIndex:0];
            NSDictionary *routeOverviewPolyline = [routeDict objectForKey:@"overview_polyline"];
            NSString *points = [routeOverviewPolyline objectForKey:@"points"];
            
            if ([self.delegate respondsToSelector:@selector(routeFetchDidReceiveResponse:)])
            {
                [self.delegate routeFetchDidReceiveResponse:points];
            }
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(routeFetchFailedWithError:)])
            {
                [self.delegate routeFetchFailedWithError:error];
            }
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(routeFetchFailedWithError:)])
        {
            [self.delegate routeFetchFailedWithError:error];
        }
    }
}

@end
