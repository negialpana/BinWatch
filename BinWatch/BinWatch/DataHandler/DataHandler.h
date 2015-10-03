//
//  DataHandler.h
//  BinWatch
//
//  Created by Supritha Nagesha on 05/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataHandler : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

+ (instancetype) sharedHandler;
- (void) insertBins:(NSArray *)bins;
- (NSArray *) fetchBins;

@end
