//
//  BWBinCollection.h
//  BinWatch
//
//  Created by Seema Kadavan on 9/5/15.
//  Copyright (c) 2015 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWBin.h"

// TODO: This class will be removed
@interface BWBinCollection : NSObject

@property (atomic, copy) NSMutableArray *bins;

+ (BWBinCollection *)sharedInstance;
- (void) addBin:(BWBin *)bin;

@end
