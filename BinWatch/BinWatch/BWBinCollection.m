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
    }
    
    return self;
    
}

- (void) addBin:(BWBin *)bin
{
    [_bins addObject:bin];
}

@end
