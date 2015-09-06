//
//  ConnectionHandler.m
//  BinWatch
//
//  Created by Supritha Nagesha on 05/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "ConnectionHandler.h"

#define kRootUrl  @"http://binwatch-ghci.rhcloud.com"

@interface ConnectionHandler  ()<NSURLSessionDelegate>

@property (nonatomic, retain) NSURLSession *session;

@end

@implementation ConnectionHandler

+ (instancetype)sharedInstance{
    
    static ConnectionHandler *connectionHandler = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        connectionHandler = [[ConnectionHandler alloc] init];
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

- (void)getBinsWithCompletionHandler:(void(^)(NSArray *, NSError *))completionBlock{
 
   NSURL *url = [NSURL URLWithString:kRootUrl];
    
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

@end
