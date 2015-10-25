//
//  BWAnalyseTableViewCell.h
//  BinWatch
//
//  Created by Supritha Nagesha on 10/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BWAnalyseTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *selectionBtn;
@property (weak, nonatomic) IBOutlet UILabel *binDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *fillPercentLabel;
- (IBAction)selBtnTapped:(id)sender;

@end
