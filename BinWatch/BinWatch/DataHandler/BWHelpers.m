//
//  BWHelpers.m
//  BinWatch
//
//  Created by Ponnie Rohith on 06/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWHelpers.h"
#import "BWConstants.h"
#import "BWBin.h"
#import "MBProgressHUD.h"

NSString* const latitude = @"latitude";
NSString* const longitude = @"longitude";
NSString* const humidity = @"humidity";
NSString* const binColor = @"binColor";
NSString* const date = @"date";
NSString* const temperature = @"temperature";
NSString* const fillPercent = @"fill"; 

@implementation BWHelpers

void runOnMainThread(void(^block)(void))
{
    if ([NSThread isMainThread])
        block();
    else
        dispatch_async(dispatch_get_main_queue(), block);
}

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
    BWBinColor binColor = [color integerValue];
    switch (binColor)
    {
//        case BWRed:
//        case BWGreen:
//            return White;
//            break;
//        case BWYellow:
//            return Black;
//            break;
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
        
        NSRange range = [string rangeOfString:@"Bengaluru"];
        if (range.location != NSNotFound) {
            
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

+ (void) displayHud:(NSString *)message onView:(UIView *)view
{
    runOnMainThread(^{
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:HUD];
        
        // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
        // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
        HUD.customView = [[UIImageView alloc] initWithImage:nil];
        
        // Set custom view mode
        HUD.mode = MBProgressHUDModeCustomView;
        
        //HUD.delegate = self;
        HUD.labelText = message;
        
        [HUD show:YES];
        [HUD hide:YES afterDelay:1];
    });

}

+ (NSError *)generateError:(NSString *)errorMsg
{
    NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:errorMsg forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"BWErrorDomain" code:1 userInfo:errorInfo];
}

@end
