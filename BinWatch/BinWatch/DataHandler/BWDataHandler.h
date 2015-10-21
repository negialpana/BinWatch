//
//  BWDataHandler.h
//  BinWatch
//
//  Created by Supritha Nagesha on 05/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BWDataHandler : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

+ (instancetype) sharedHandler;
- (void) insertBins:(NSArray *)bins;
- (NSArray *) fetchBins;

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
