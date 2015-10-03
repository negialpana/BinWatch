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

- (void) initBins
{
    [self flushBins];
    
    BWBin *bin1 = [[BWBin alloc] init];
    bin1.binID = @"55e5e26c3523045d3a387fda";
    bin1.isAcive = YES;
    bin1.temperature = [NSNumber numberWithFloat:85.8747];
    bin1.humidity = [NSNumber numberWithFloat:35];
    //bin.date = [NSDate da];
    bin1.fill = [NSNumber numberWithFloat:40];
    bin1.latitude = [NSNumber numberWithFloat:12.927803];
    bin1.longitude = [NSNumber numberWithFloat:77.609117];
    
    bin1.color = [NSNumber numberWithInt:1];
    bin1.place = @"Hello";


    BWBin *bin2 = [[BWBin alloc] init];
    bin2.binID = @"55e5e26cba6c3cbb0ccd9a09";
    bin2.isAcive = YES;
    bin2.temperature = [NSNumber numberWithFloat:61.7448];
    bin2.humidity = [NSNumber numberWithFloat:58];
    //bin.date = [NSDate da];
    bin2.fill = [NSNumber numberWithFloat:50];
    bin2.latitude = [NSNumber numberWithFloat:12.928702];
    bin2.longitude = [NSNumber numberWithFloat:77.605448];
    
    bin2.color = [NSNumber numberWithInt:1];
    bin2.place = @"Hello";

    [_bins addObject:bin2];
    
    
    BWBin *bin3 = [[BWBin alloc] init];
    bin3.binID = @"55e5e26c9014bdd8b07e7d9c";
    bin3.isAcive = YES;
    bin3.temperature = [NSNumber numberWithFloat:54];
    bin3.humidity = [NSNumber numberWithFloat:62];
    //bin.date = [NSDate da];
    bin3.fill = [NSNumber numberWithFloat:10];
    bin3.latitude = [NSNumber numberWithFloat:12.926464];
    bin3.longitude = [NSNumber numberWithFloat:77.600823];
    
    bin3.color = [NSNumber numberWithInt:1];
    bin3.place = @"Hello";
    
    [_bins addObject:bin3];
    
    BWBin *bin4 = [[BWBin alloc] init];
    bin4.binID = @"55e5e26c3523045d3a387fda";
    bin4.isAcive = YES;
    bin4.temperature = [NSNumber numberWithFloat:26];
    bin4.humidity = [NSNumber numberWithFloat:14];
    //bin.date = [NSDate da];
    bin4.fill = [NSNumber numberWithFloat:70];
    bin4.latitude = [NSNumber numberWithFloat:12.927991];
    bin4.longitude = [NSNumber numberWithFloat:77.603817];
    
    bin4.color = [NSNumber numberWithInt:2];
    bin4.place = @"Hello";
    
    [_bins addObject:bin4];

    BWBin *bin5 = [[BWBin alloc] init];
    bin5.binID = @"55e5e26c3dc3edcf54283569";
    bin5.isAcive = YES;
    bin5.temperature = [NSNumber numberWithFloat:28];
    bin5.humidity = [NSNumber numberWithFloat:44];
    //bin.date = [NSDate da];
    bin5.fill = [NSNumber numberWithFloat:30];
    bin5.latitude = [NSNumber numberWithFloat:12.927761];
    bin5.longitude = [NSNumber numberWithFloat:77.607668];
    
    bin5.color = [NSNumber numberWithInt:1];
    bin5.place = @"Hello";
    
    [_bins addObject:bin5];

    BWBin *bin6 = [[BWBin alloc] init];
    bin6.binID = @"55e5e26cc82b214c605e79bd";
    bin6.isAcive = YES;
    bin6.temperature = [NSNumber numberWithFloat:89];
    bin6.humidity = [NSNumber numberWithFloat:47];
    //bin.date = [NSDate da];
    bin6.fill = [NSNumber numberWithFloat:20];
    bin6.latitude = [NSNumber numberWithFloat:12.925460];
    bin6.longitude = [NSNumber numberWithFloat:77.607604];
    
    bin6.color = [NSNumber numberWithInt:1];
    bin6.place = @"Hello";
    
    [_bins addObject:bin6];

    BWBin *bin7 = [[BWBin alloc] init];
    bin7.binID = @"55e5e26c35d45c5a3d81bed8";
    bin7.isAcive = YES;
    bin7.temperature = [NSNumber numberWithFloat:63];
    bin7.humidity = [NSNumber numberWithFloat:93];
    //bin.date = [NSDate da];
    bin7.fill = [NSNumber numberWithFloat:90];
    bin7.latitude = [NSNumber numberWithFloat:12.924780];
    bin7.longitude = [NSNumber numberWithFloat:77.601703];
    
    bin7.color = [NSNumber numberWithInt:1];
    bin7.place = @"Hello";
    
    [_bins addObject:bin7];
    
}

@end
