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

- (void) flushBins
{
    _bins = nil;
    _bins = [[NSMutableArray alloc] init];
}

- (void) addBin:(BWBin *)bin
{
    [_bins addObject:bin];
}

#pragma mark - Testing Function

//TODO : remove at later point when all values are perfect
- (void) initBins
{
    [self flushBins];
    
    for (int binNo = 0; binNo < 10; binNo++) {
        BWBin *bin = [[BWBin alloc] init];
        bin.isAcive = YES;
        bin.temperature = [NSNumber numberWithFloat:(arc4random()%100)];
        bin.humidity = [NSNumber numberWithFloat:(10+arc4random()%90)];
        bin.fill = [NSNumber numberWithFloat:(arc4random()%100)];
        bin.latitude = [NSNumber numberWithFloat:(float)(12.9667+binNo)];
        bin.longitude = [NSNumber numberWithFloat:(float)(77.5667+binNo)];
        
        bin.color = [NSNumber numberWithInt:(arc4random()%3)];
        bin.place = @"Hello";
        bin.date = [NSDate date];
        
        bin.binID = [NSString stringWithFormat:@"%d", 100 + binNo];
        
        [self addBin:bin];
    }
}

@end
