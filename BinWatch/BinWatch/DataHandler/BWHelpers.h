//
//  BWHelpers.h
//  BinWatch
//
//  Created by Ponnie Rohith on 06/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BWConstants.h"
@interface BWHelpers : NSObject

void runOnMainThread(void(^block)(void));

/**
 Returns the URL to the application's documents directory.
 */
+ (NSURL *)applicationDocumentsDirectory;

//+(NSArray*)binsArrayFromJSonArray:(NSArray*)bins;
//+(BWBinColor)colorForPercent:(float)fillPercent;

+ (int) colorForPercent:(float)fillPercent;
+ (UIColor*) textColorForBinColor:(NSNumber *)color;
+ (NSString *)areanameFromFullAddress : (NSString*)fullAddress;
+ (float)currentOSVersion;
+ (void) displayHud:(NSString *)message onView:(UIView *)view;
+ (NSError *)generateError:(NSString *)errorMsg;
+ (NSString *)generateUniqueFilePath;
+ (NSString *)getPresentDateTimeString;

@end
