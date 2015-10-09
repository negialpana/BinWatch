//
//  BWDatePickerView.m
//  BinWatch
//
//  Created by Supritha Nagesha on 09/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWDatePickerView.h"

@interface BWDatePickerView ()

@property (nonatomic, strong) NSDate *selectedDate;

- (IBAction)donePressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;

@end

@implementation BWDatePickerView

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        //any initialization in future
    }
    return self;
}

- (void)awakeFromNib{
    self.selectedDate = _datePickerView.date;
}

- (IBAction)donePressed:(id)sender {
    self.selectedDate = _datePickerView.date;
    self.complBlock(self.selectedDate);
    [self removeFromSuperview];
}

- (IBAction)cancelPressed:(id)sender {
    [self removeFromSuperview];
}

@end
