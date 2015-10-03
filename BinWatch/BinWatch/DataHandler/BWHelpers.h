//
//  BWHelpers.h
//  BinWatch
//
//  Created by Ponnie Rohith on 06/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BWCommon.h"
@interface BWHelpers : NSObject

/**
 Returns the URL to the application's documents directory.
 */
+ (NSURL *)applicationDocumentsDirectory;

//+(NSArray*)binsArrayFromJSonArray:(NSArray*)bins;
//+(BWBinColor)colorForPercent:(float)fillPercent;

+ (int) colorForPercent:(float)fillPercent;
+ (UIColor*) textColorForBinColor:(NSNumber *)color;
@end
