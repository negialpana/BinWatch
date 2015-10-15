//
//  BWConnectionHandler.m
//  BinWatch
//
//  Created by Supritha Nagesha on 05/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWConnectionHandler.h"
#import "BWHelpers.h"

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
//TODO : modify method to get bins from a place
- (void)getBinsAtPlace:(NSString*)place WithCompletionHandler:(void(^)(NSArray *, NSError *))completionBlock{
    [self getBinsWithCompletionHandler:completionBlock];
}

- (void)getBinsWithCompletionHandler:(void(^)(NSArray *, NSError *))completionBlock{
 
   NSURL *url = [self rootURL];
    
   NSURLSessionDataTask *dataTask = [_session dataTaskWithURL:[url URLByAppendingPathComponent:@"bins"]
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                NSError *jsonError = nil;
                                                if (!error) {
                                                    NSArray * bins = [NSJSONSerialization JSONObjectWithData:data
                                                                                                     options:NSJSONReadingAllowFragments
                                                                                                       error:&jsonError];
                                                    completionBlock(bins,jsonError);
                                                }else {
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
@end
