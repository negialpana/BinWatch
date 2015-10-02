//
//  BWBinCollection.m
//  BinWatch
//
//  Created by Seema Kadavan on 9/5/15.
//  Copyright (c) 2015 AirWatch. All rights reserved.
//

#import "BWBinCollection.h"

@implementation BWBinCollection

+ (BWBinCollection *)sharedInstance
{
    static dispatch_once_t onceToken;
    static BWBinCollection *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BWBinCollection alloc] init];
    });
    
    return instance;
}

- (id) init
{
    if (self = [super init])
    {
        _bins = [[NSMutableArray alloc] init];
        [self initBins];
    }
    
    return self;
    
}

- (void) addBin:(BWBin *)bin
{
    [_bins addObject:bin];
}

#pragma mark - Testing Function

// TODO : remove when actual data comes up
- (void) initBins
{
    for (int binNo = 0; binNo < 10; binNo++) {
        BWBin *bin = [[BWBin alloc] initWith:12.9667+binNo longitude:77.5667+binNo binColor:(arc4random()%3) fillPercent: (arc4random()%100)];
        bin.binID = [NSString stringWithFormat:@"%d", 100 + binNo];
        
        [self addBin:bin];
    }
}

@end
