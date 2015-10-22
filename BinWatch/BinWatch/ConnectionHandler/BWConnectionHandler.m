//
//  BWConnectionHandler.m
//  BinWatch
//
//  Created by Supritha Nagesha on 05/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWConnectionHandler.h"
#import "BWHelpers.h"
#import "BWDataHandler.h"

#define kRootUrl  @"http://binwatch-ghci.rhcloud.com"

@interface BWConnectionHandler  ()<NSURLSessionDelegate>

@property (nonatomic, retain) NSURLSession *session;

@end

@implementation BWConnectionHandler

+ (instancetype)sharedInstance{
    
    static BWConnectionHandler *connectionHandler = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        connectionHandler = [[BWConnectionHandler alloc] init];
    });
    return connectionHandler;
}

- (instancetype) init{
    
    if (self = [super init]) {
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:self
                                            delegateQueue:nil];
    }
    
    return self;
}

- (void)getBinsAtPlace:(CLLocation*)location WithCompletionHandler:(void(^)(NSArray *, NSError *))completionBlock{
    [self getBinsWithCompletionHandler:completionBlock];
}

- (void)getBinData:(NSString *)binID from:(long)utcFrom to:(long)utcTo WithCompletionHandler:(void(^)(NSArray *, NSError *))completionBlock{
    NSURL *url = [self rootURL];
    
    //TODO: Change URL
    NSURLSessionDataTask *dataTask = [_session dataTaskWithURL:[url URLByAppendingPathComponent:@"get/bins"]
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                 NSError *jsonError = nil;
                                                 if (!error) {
                                                     NSArray * bins = [NSJSONSerialization JSONObjectWithData:[self dummyBinData]
                                                                                                      options:NSJSONReadingAllowFragments
                                                                                                        error:&jsonError];
                                                     completionBlock(bins,jsonError);
                                                 }else {
                                                     completionBlock(nil,error);
                                                 }
                                             }];
    [dataTask resume];
}

- (void)getBinsWithCompletionHandler:(void(^)(NSArray *, NSError *))completionBlock{
 
   NSURL *url = [self rootURL];
   NSURLSessionDataTask *dataTask = [_session dataTaskWithURL:[url URLByAppendingPathComponent:@"get/bins"]
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

                                                NSError *jsonError = nil;
                                                if (!error)
                                                {
                                                    NSArray * bins = [NSJSONSerialization JSONObjectWithData:data
                                                                                                     options:NSJSONReadingAllowFragments
                                                                                                       error:&jsonError];
                                                    [[BWDataHandler sharedHandler] insertBins:bins];
                                                    completionBlock(bins,jsonError);
                                                }
                                                else
                                                {
                                                    completionBlock(nil,error);
                                                }
                                            }];
  [dataTask resume];
    
}

- (NSURL *)rootURL
{
    NSString *rootURLString = kRootUrl;
    if([BWHelpers currentOSVersion] >= 9.0)
        rootURLString = [kRootUrl stringByReplacingOccurrencesOfString:@"http" withString:@"https"];
        
    return [NSURL URLWithString:rootURLString];
}

-(NSData *) dummyBinData
{
    
    NSMutableDictionary *bin1 = [[NSMutableDictionary alloc] init];
    [bin1 setValue:@"55e5e26c3523045d3a387fda" forKey:@"_id"];
    [bin1 setValue:[NSNumber numberWithBool:YES] forKey:@"isActive"];
    [bin1 setValue:@"Bangalore" forKey:@"name"];
    [bin1 setValue:@"dry" forKey:@"type"];
    [bin1 setValue:[NSNumber numberWithFloat:26.5] forKey:@"temperature"];
    [bin1 setValue:[NSNumber numberWithFloat:14.5] forKey:@"humidity"];
    [bin1 setValue:@"40" forKey:@"fill"];
    [bin1 setValue:[NSNumber numberWithFloat:12.927991] forKey:@"latitude"];
    [bin1 setValue:[NSNumber numberWithFloat:77.603817] forKey:@"longitude"];
    [bin1 setValue:[NSNumber numberWithLong:1445362953] forKey:@"date"];
    
    NSMutableDictionary *bin2 = [[NSMutableDictionary alloc] init];
    [bin2 setValue:@"55e5e26c3523045d3a387fda" forKey:@"_id"];
    [bin2 setValue:[NSNumber numberWithBool:YES] forKey:@"isActive"];
    [bin2 setValue:@"Bangalore" forKey:@"name"];
    [bin2 setValue:@"dry" forKey:@"type"];
    [bin2 setValue:[NSNumber numberWithFloat:27.5] forKey:@"temperature"];
    [bin2 setValue:[NSNumber numberWithFloat:10.5] forKey:@"humidity"];
    [bin2 setValue:@"70" forKey:@"fill"];
    [bin2 setValue:[NSNumber numberWithFloat:12.927991] forKey:@"latitude"];
    [bin2 setValue:[NSNumber numberWithFloat:77.603817] forKey:@"longitude"];
    [bin2 setValue:[NSNumber numberWithLong:1445352993] forKey:@"date"];
    
    NSMutableDictionary *bin3 = [[NSMutableDictionary alloc] init];
    [bin3 setValue:@"55e5e26c3523045d3a387fda" forKey:@"_id"];
    [bin3 setValue:[NSNumber numberWithBool:YES] forKey:@"isActive"];
    [bin3 setValue:@"Bangalore" forKey:@"name"];
    [bin3 setValue:@"dry" forKey:@"type"];
    [bin3 setValue:[NSNumber numberWithFloat:20.5] forKey:@"temperature"];
    [bin3 setValue:[NSNumber numberWithFloat:17.5] forKey:@"humidity"];
    [bin3 setValue:@"10" forKey:@"fill"];
    [bin3 setValue:[NSNumber numberWithFloat:12.927991] forKey:@"latitude"];
    [bin3 setValue:[NSNumber numberWithFloat:77.603817] forKey:@"longitude"];
    [bin3 setValue:[NSNumber numberWithLong:1445253092] forKey:@"date"];
    
    NSMutableDictionary *bin4 = [[NSMutableDictionary alloc] init];
    [bin4 setValue:@"55e5e26c3523045d3a387fda" forKey:@"_id"];
    [bin4 setValue:[NSNumber numberWithBool:YES] forKey:@"isActive"];
    [bin4 setValue:@"Bangalore" forKey:@"name"];
    [bin4 setValue:@"dry" forKey:@"type"];
    [bin4 setValue:[NSNumber numberWithFloat:22.5] forKey:@"temperature"];
    [bin4 setValue:[NSNumber numberWithFloat:15.5] forKey:@"humidity"];
    [bin4 setValue:@"33" forKey:@"fill"];
    [bin4 setValue:[NSNumber numberWithFloat:12.927991] forKey:@"latitude"];
    [bin4 setValue:[NSNumber numberWithFloat:77.603817] forKey:@"longitude"];
    [bin4 setValue:[NSNumber numberWithLong:1445252993] forKey:@"date"];
    
    NSMutableDictionary *bin5 = [[NSMutableDictionary alloc] init];
    [bin5 setValue:@"55e5e26c3523045d3a387fda" forKey:@"_id"];
    [bin5 setValue:[NSNumber numberWithBool:YES] forKey:@"isActive"];
    [bin5 setValue:@"Bangalore" forKey:@"name"];
    [bin5 setValue:@"dry" forKey:@"type"];
    [bin5 setValue:[NSNumber numberWithFloat:28.7] forKey:@"temperature"];
    [bin5 setValue:[NSNumber numberWithFloat:9.5] forKey:@"humidity"];
    [bin5 setValue:@"37" forKey:@"fill"];
    [bin5 setValue:[NSNumber numberWithFloat:12.927991] forKey:@"latitude"];
    [bin5 setValue:[NSNumber numberWithFloat:77.603817] forKey:@"longitude"];
    [bin5 setValue:[NSNumber numberWithLong:1445283092] forKey:@"date"];
    
    NSMutableDictionary *bin6 = [[NSMutableDictionary alloc] init];
    [bin6 setValue:@"55e5e26c3523045d3a387fda" forKey:@"_id"];
    [bin6 setValue:[NSNumber numberWithBool:YES] forKey:@"isActive"];
    [bin6 setValue:@"Bangalore" forKey:@"name"];
    [bin6 setValue:@"dry" forKey:@"type"];
    [bin6 setValue:[NSNumber numberWithFloat:28.7] forKey:@"temperature"];
    [bin6 setValue:[NSNumber numberWithFloat:9.5] forKey:@"humidity"];
    [bin6 setValue:@"37" forKey:@"fill"];
    [bin6 setValue:[NSNumber numberWithFloat:12.927991] forKey:@"latitude"];
    [bin6 setValue:[NSNumber numberWithFloat:77.603817] forKey:@"longitude"];
    [bin6 setValue:[NSNumber numberWithLong:1445288092] forKey:@"date"];
    
    NSMutableDictionary *bin7 = [[NSMutableDictionary alloc] init];
    [bin7 setValue:@"55e5e26c3523045d3a387fda" forKey:@"_id"];
    [bin7 setValue:[NSNumber numberWithBool:YES] forKey:@"isActive"];
    [bin7 setValue:@"Bangalore" forKey:@"name"];
    [bin7 setValue:@"dry" forKey:@"type"];
    [bin7 setValue:[NSNumber numberWithFloat:33.7] forKey:@"temperature"];
    [bin7 setValue:[NSNumber numberWithFloat:19.5] forKey:@"humidity"];
    [bin7 setValue:@"55" forKey:@"fill"];
    [bin7 setValue:[NSNumber numberWithFloat:12.927991] forKey:@"latitude"];
    [bin7 setValue:[NSNumber numberWithFloat:77.603817] forKey:@"longitude"];
    [bin7 setValue:[NSNumber numberWithLong:1445278092] forKey:@"date"];
    
    NSMutableDictionary *bin8 = [[NSMutableDictionary alloc] init];
    [bin8 setValue:@"55e5e26c3523045d3a387fda" forKey:@"_id"];
    [bin8 setValue:[NSNumber numberWithBool:YES] forKey:@"isActive"];
    [bin8 setValue:@"Bangalore" forKey:@"name"];
    [bin8 setValue:@"dry" forKey:@"type"];
    [bin8 setValue:[NSNumber numberWithFloat:31.7] forKey:@"temperature"];
    [bin8 setValue:[NSNumber numberWithFloat:14.5] forKey:@"humidity"];
    [bin8 setValue:@"65" forKey:@"fill"];
    [bin8 setValue:[NSNumber numberWithFloat:12.927991] forKey:@"latitude"];
    [bin8 setValue:[NSNumber numberWithFloat:77.603817] forKey:@"longitude"];
    [bin8 setValue:[NSNumber numberWithLong:1445363341] forKey:@"date"];
    
    NSMutableDictionary *bin9 = [[NSMutableDictionary alloc] init];
    [bin9 setValue:@"55e5e26c3523045d3a387fda" forKey:@"_id"];
    [bin9 setValue:[NSNumber numberWithBool:YES] forKey:@"isActive"];
    [bin9 setValue:@"Bangalore" forKey:@"name"];
    [bin9 setValue:@"dry" forKey:@"type"];
    [bin9 setValue:[NSNumber numberWithFloat:25.7] forKey:@"temperature"];
    [bin9 setValue:[NSNumber numberWithFloat:10.5] forKey:@"humidity"];
    [bin9 setValue:@"0" forKey:@"fill"];
    [bin9 setValue:[NSNumber numberWithFloat:12.927991] forKey:@"latitude"];
    [bin9 setValue:[NSNumber numberWithFloat:77.603817] forKey:@"longitude"];
    [bin9 setValue:[NSNumber numberWithLong:1445323341] forKey:@"date"];
    
    NSMutableDictionary *bin0 = [[NSMutableDictionary alloc] init];
    [bin0 setValue:@"55e5e26c3523045d3a387fda" forKey:@"_id"];
    [bin0 setValue:[NSNumber numberWithBool:YES] forKey:@"isActive"];
    [bin0 setValue:@"Bangalore" forKey:@"name"];
    [bin0 setValue:@"dry" forKey:@"type"];
    [bin0 setValue:[NSNumber numberWithFloat:26.7] forKey:@"temperature"];
    [bin0 setValue:[NSNumber numberWithFloat:11.5] forKey:@"humidity"];
    [bin0 setValue:@"15" forKey:@"fill"];
    [bin0 setValue:[NSNumber numberWithFloat:12.927991] forKey:@"latitude"];
    [bin0 setValue:[NSNumber numberWithFloat:77.603817] forKey:@"longitude"];
    [bin0 setValue:[NSNumber numberWithLong:1445383400] forKey:@"date"];
    
    
    NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
    [jsonArray addObject:bin1];
    [jsonArray addObject:bin2];
    [jsonArray addObject:bin3];
    [jsonArray addObject:bin4];
    [jsonArray addObject:bin5];
    [jsonArray addObject:bin6];
    [jsonArray addObject:bin7];
    [jsonArray addObject:bin8];
    [jsonArray addObject:bin9];
    [jsonArray addObject:bin0];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    return jsonData;
//    NSError *jsonError = nil;
//    NSArray * bins = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                     options:NSJSONReadingAllowFragments
//                                                       error:&jsonError];
}
@end
