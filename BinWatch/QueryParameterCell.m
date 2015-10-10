//
//  QueryParameterCell.m
//  BinWatch
//
//  Created by Supritha Nagesha on 06/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "QueryParameterCell.h"

@interface QueryParameterCell ()


@end

@implementation QueryParameterCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)btnTapped:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    self.isParamSelected = btn.selected;
    
}
@end
