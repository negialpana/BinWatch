//
//  BWAppSettings.h
//  BinWatch
//
//  Created by Seema Kadavan on 10/11/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWDataHandler.h"

// UserDefaults
static NSString* const kCoverageRadius = @"Radius";
static NSString* const kSupportMailID = @"MailID";
static NSString* const kExportPDFOn = @"PDF";
static NSString* const kExportExcelOn = @"EXCEL";
static NSString* const kExportCSVOn = @"CSV";
static NSString* const kAppMode = @"AppMode";

#define DEFAULT_RADIUS 5

@interface BWAppSettings : NSObject

+ (BWAppSettings *)sharedInstance;

-(void)switchedAppMode;
-(void)exportSelected;
-(void)settingsSelected;
-(void)requestBinSelected;
-(void)reportIssueSelected;
-(void)reportBinSelected;


- (void) saveAppMode:(BWAppMode)mode;
- (BWAppMode) getAppMode;

- (void) saveSupportMailID:(NSString *)mailID;
- (NSString *) getSupportMailID;

- (void) saveCoverageRadius:(int)radius;
- (int) getCoverageRadius;

- (void) saveExportPDF:(bool)enable;
- (bool) getExportPDF;

- (void) saveExportExcel:(bool)enable;
- (bool) getExportExcel;

- (void) saveExportCSV:(bool)enable;
- (bool) getExportCSV;

@end
