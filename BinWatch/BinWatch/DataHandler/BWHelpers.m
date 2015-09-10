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
+(CAGradientLayer*)gradientLayerForView:(UIView*)view withColor:(BWBinColor)color
{
    UIColor *first,*last;
    switch (color) {
        case BWGreen:
            first = DarkGreen;
            last = LightGreen;
            break;
        case BWYellow:
            first = DarkYellow;
            last = LightYellow;
            break;
        case BWRed:
            first = DarkRed;
            last = LightRed;
            break;
            
        default:
            first = DarkGreen;
            last = LightGreen;
            break;
    }
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//    gradientLayer.frame = self.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[first CGColor],(id)[last CGColor], nil];
    gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    gradientLayer.endPoint = CGPointMake(1.0, 0.0);
    //        gradient.locations = @[@0.0,@1.0];
    gradientLayer.frame = view.bounds;
    [view.layer insertSublayer:gradientLayer atIndex:0];
    return gradientLayer;
}
@end
