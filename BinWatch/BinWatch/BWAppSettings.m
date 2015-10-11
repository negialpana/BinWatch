//
//  BWAppSettings.m
//  BinWatch
//
//  Created by Seema Kadavan on 10/11/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWAppSettings.h"

@implementation BWAppSettings

+ (BWAppSettings *)sharedInstance
{
    static dispatch_once_t onceToken;
    static BWAppSettings *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BWAppSettings alloc] init];
    });
    
    return instance;
}

@end
