//
//  BWConnectionHandler.h
//  BinWatch
//
//  Created by Supritha Nagesha on 05/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CLLocation.h"

typedef NS_ENUM(NSUInteger, BWBinParam) {
    BWFillPercentage,
    BWHumidity,
    BWTemperature,
};

@interface BWConnectionHandler : NSObject

+ (instancetype)sharedInstance;

- (void)getBinsWithCompletionHandler:(void(^)(NSArray *, NSError *))completionBlock;
- (void)getBinsAtPlace:(CLLocation*)location withAddress:(NSString *)address WithCompletionHandler:(void(^)(NSArray *, NSError *))completionBlock;

/*
NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:1301011200];
NSDate *dateTo = [NSDate dateWithTimeIntervalSince1970:1478822400];
[[BWConnectionHandler sharedInstance] getBinData:@"5603a582990b1b67be000002" from:dateFrom to:dateTo forParam:BWHumidity
                           WithCompletionHandler:^(NSArray *binData, NSError *error) {
                               if (!error) {
                                   NSLog(@"*********Bins: %@", binData);
                               } else
                               {
                                   NSLog(@"%@", [error localizedDescription]);
                               }
                           }];
*/
- (void)getBinData:(NSString *)binID from:(NSDate *)utcFrom to:(NSDate *)utcTo forParam:(BWBinParam)param WithCompletionHandler:(void(^)(NSArray *, NSError *))completionBlock;
- (void)getNextFillForBinWithId:(NSString*)binId andCompletionBlock:(void(^)(NSDate *, NSError *))completionBlock;

@end
