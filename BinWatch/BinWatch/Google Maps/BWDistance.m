//
//  BWDistance.m
//  BinWatch
//
//  Created by Seema Kadavan on 10/29/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWDistance.h"
#import "BWHelpers.h"
#import "BWConstants.h"

@interface BWDistance () <NSURLSessionDelegate>

@property (nonatomic, retain) NSURLSession *session;

@end

@implementation BWDistance
{
    NSMutableData *responseData;
}

+ (BWDistance *)sharedInstance
{
    static dispatch_once_t onceToken;
    static BWDistance *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BWDistance alloc] init];
    });
    
    return instance;
}

- (id) init
{
    if (self = [super init])
    {
        responseData = [[NSMutableData alloc] init];
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:self
                                            delegateQueue:nil];

    }
    
    return self;
}

-(void)getDistancefrom:(CLLocation *)fromLoc
                    to:(CLLocation *)toLoc
    andCompletionBlock:(void(^)(NSNumber *, CLLocation *, NSError *))completionBlock
{
    
    NSMutableString *urlReq = [NSMutableString stringWithFormat:@"https://maps.googleapis.com/maps/api/distancematrix/json?origins=%f,%f&destinations=%f,%f&mode=driving&language=fr-FR&key=%@", fromLoc.coordinate.latitude, fromLoc.coordinate.longitude, toLoc.coordinate.latitude, toLoc.coordinate.longitude, kGoogleAPIKey_Browser];
    
    NSURL *url = [NSURL URLWithString:[urlReq stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *dataTask = [_session dataTaskWithURL:url
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
             if(!error)
             {
                 NSMutableArray *distances = [[NSMutableArray alloc] init];
                 NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

                 if (!error)
                 {
                     NSArray *routesArray = [json objectForKey:@"rows"];
                     
                     for(NSDictionary *elements in routesArray)
                     {
                         NSArray *routeDict = [elements objectForKey:@"elements"];
                         for(NSDictionary *ddd in routeDict)
                         {
                             NSDictionary *myDict = [ddd objectForKey:@"duration"];
                             long value = [[myDict objectForKey:@"value"] floatValue];
                             [distances addObject:[NSNumber numberWithLong:value]];
                         }
                     }
                     NSArray *sortedDistances = [distances sortedArrayUsingSelector:@selector(compare:)];
                     if([sortedDistances count] > 0)
                         completionBlock([sortedDistances objectAtIndex:0],toLoc,error);
                     else
                         completionBlock([NSNumber numberWithInt:0],toLoc,[BWHelpers generateError:@"Incorrect Data"]);
                 }
                 else{
                     completionBlock([NSNumber numberWithInt:0],toLoc,[BWHelpers generateError:@"Incorrect Data"]);
                 }
             }
             else
             {
                 completionBlock([NSNumber numberWithInt:0],toLoc,[BWHelpers generateError:@"Incorrect Data"]);

             }
    }];
    [dataTask resume];
}
@end
