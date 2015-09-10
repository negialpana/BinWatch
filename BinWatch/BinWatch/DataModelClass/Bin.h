//
//  Bin.h
//  BinWatch
//
//  Created by Supritha Nagesha on 06/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Bin : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * humidity;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, assign) BOOL isAcive;
@property (nonatomic, retain) NSNumber * latutude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * temperature;
@property (nonatomic, retain) NSString * bincolor;

@end
