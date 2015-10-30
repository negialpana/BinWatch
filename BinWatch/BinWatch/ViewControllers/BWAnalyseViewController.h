//
//  BWAnalyseViewController.h
//  BinWatch
//
//  Created by Supritha Nagesha on 10/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface BWAnalyseViewController : UIViewController
@property (nonatomic, strong) NSArray *bins;
@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;
@property (nonatomic, strong) NSString *query;

@property (weak, nonatomic) IBOutlet UIView *bezirGraphView;

@end
