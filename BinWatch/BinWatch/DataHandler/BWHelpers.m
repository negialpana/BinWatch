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
NSString* const fillPercent = @"fill"; 
@implementation BWHelpers

/**
 Returns the URL to the application's documents directory.
 */
+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

//+(NSArray*)binsArrayFromJSonArray:(NSArray*)bins
//{
//    NSMutableArray *binsArray = [NSMutableArray new];
//    for (int i=0; i < bins.count; i++) {
//        double lat = [[bins[i] valueForKey:latitude] doubleValue];
//        double lon = [[bins[i] valueForKey:longitude] doubleValue];
//        float fill = [[bins[i] valueForKey:fillPercent] floatValue];
//
////        BWBin *bin = [[BWBin alloc] initWith:[NSNumber numberWithDouble:lat] longitude:[NSNumber numberWithDouble:lon] binColor:[self colorForPercent:fill] fillPercent:fill];
////        [binsArray addObject:bin];
//    }
//    
//    return binsArray;
//}

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

//+(BWBinColor)colorForPercent:(float)fillPercent
//{
//    if (fillPercent > 70) {
//        return  BWRed;
//    }
//    if (fillPercent > 50) {
//        return  BWYellow;
//    }
//    
//    return BWGreen;
//}

+ (int) colorForPercent:(float)fillPercent
{
    if (fillPercent > RED_BOUNDARY) {
        return  0;
    }
    if (fillPercent > YELLOW_BOUNDARY) {
        return  2;
    }
    
    return 1;
}

+ (UIColor*) textColorForBinColor:(NSNumber *)color
{
    int binColor = [color integerValue];
    switch (binColor)
    {
        case BWRed:
        case BWGreen:
            return White;
            break;
        case BWYellow:
            return Black;
            break;
        default:
            return Black;
            break;
    }
}

+ (NSString *)areanameFromFullAddress : (NSString*)fullAddress
{
    NSString *areaname = @"areaname";
    NSArray *arrayOfAddressStrings = [fullAddress componentsSeparatedByString:@","];
    int indexOfAreaName = -1;
    for (NSString *string in arrayOfAddressStrings) {
        //todo improvement : it would be better if the street address, areaname, city are given with header and deliminator as area : BTM layout, city : Bengaluru. In that case we can just scan for "area :" header to get the area name instead of hard-coding the cityname as Bengaluru.
        if([string containsString:@"Bengaluru"])
        {
            break;
        }
        indexOfAreaName++;
    }
    if(indexOfAreaName >= 0)
        areaname = [arrayOfAddressStrings objectAtIndex:indexOfAreaName];
    return areaname;
}

+ (float)currentOSVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

@end
