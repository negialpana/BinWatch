//
//  BWHelpers.m
//  BinWatch
//
//  Created by Ponnie Rohith on 06/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWHelpers.h"
#import "BWCommon.h"
#import "BWBin.h"

NSString* const latitude = @"latitude";
NSString* const longitude = @"longitude";
NSString* const humidity = @"humidity";
NSString* const binColor = @"binColor";
NSString* const date = @"date";
NSString* const temperature = @"temperature";
NSString* const fillPercent = @"humidity"; // I'm taking humidity value because fillPercent is not available in the object

@implementation BWHelpers

+(NSArray*)binsArrayFromJSonArray:(NSArray*)bins
{
    NSMutableArray *binsArray = [NSMutableArray new];
    for (int i=0; i < bins.count; i++) {
        double lat = [[bins[i] valueForKey:latitude] doubleValue];
        double lon = [[bins[i] valueForKey:longitude] doubleValue];
        float fill = [[bins[i] valueForKey:fillPercent] floatValue];

        BWBin *bin = [[BWBin alloc] initWith:lat longitude:lon binColor:[self colorForPercent:fill] fillPercent:fill];
        [binsArray addObject:bin];
    }
    
    return binsArray;
}

+(BWBinColor)colorForString:(NSString*)colorString
{
    if ([colorString isEqualToString:@"green"]) {
        return BWGreen;
    }
    if ([colorString isEqualToString:@"yellow"]) {
        return BWYellow;
    }
    if ([colorString isEqualToString:@"red"]) {
        return BWRed;
    }
    return BWGreen;
}

+(BWBinColor)colorForPercent:(float)fillPercent
{
    if (fillPercent > 70) {
        return  BWRed;
    }
    if (fillPercent > 50) {
        return  BWYellow;
    }
    
    return BWGreen;
}
@end
