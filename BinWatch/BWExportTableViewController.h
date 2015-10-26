//
//  BWExportTableViewController.h
//  BinWatch
//
//  Created by Supritha Nagesha on 25/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CorePlot-CocoaTouch.h"
#import "CPDConstants.h"
#import "CPDStockPriceStore.h"
@interface BWExportTableViewController : UITableViewController <CPTBarPlotDataSource, CPTBarPlotDelegate>
@property (strong, nonatomic) IBOutlet UIView *exportView;

@end
