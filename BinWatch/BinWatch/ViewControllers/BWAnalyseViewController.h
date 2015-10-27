//
//  BWAnalyseViewController.h
//  BinWatch
//
//  Created by Supritha Nagesha on 10/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "CPDConstants.h"
#import "CPDStockPriceStore.h"

@interface BWAnalyseViewController : UIViewController<CPTBarPlotDataSource, CPTBarPlotDelegate>

@property (nonatomic, strong) NSArray *bins;
@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;
@property (nonatomic, strong) NSString *query;
@end
