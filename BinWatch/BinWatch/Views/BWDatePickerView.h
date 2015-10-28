//
//  BWDatePickerView.h
//  BinWatch
//
//  Created by Supritha Nagesha on 09/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^completionBlock)(NSDate *date);

@interface BWDatePickerView : UIView

@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerView;
@property (nonatomic, copy) completionBlock complBlock;
@property (assign) BOOL shouldRemoveFromSuperview;

@end
