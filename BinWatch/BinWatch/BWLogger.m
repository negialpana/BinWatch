//
//  BWLogger.m
//  BinWatch
//
//  Created by Seema Kadavan on 10/9/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWLogger.h"
#import <Crashlytics/Crashlytics.h>

@implementation BWLogger

+ (void) DoLog:(NSString *)logMsg
{
    CLSLog(logMsg);
}

@end
