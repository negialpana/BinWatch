//
//  BWAnalyseTableViewCell.m
//  BinWatch
//
//  Created by Supritha Nagesha on 10/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWAnalyseTableViewCell.h"

@implementation BWAnalyseTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)selBtnTapped:(id)sender forEvent:(UIEvent *)event {
    
    UITouch * touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.superview.superview];
    UITableView *tableView = (UITableView *)self.superview.superview;
    NSIndexPath * indexPath = [tableView indexPathForRowAtPoint: location];
    [tableView.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (IBAction)selBtnTapped:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
}
@end
