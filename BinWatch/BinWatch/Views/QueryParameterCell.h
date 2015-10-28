//
//  QueryParameterCell.h
//  BinWatch
//
//  Created by Supritha Nagesha on 06/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QueryParameterCell : UITableViewCell

@property (nonatomic, assign) BOOL isParamSelected;
@property (weak, nonatomic) IBOutlet UILabel *queryString;
@property (weak, nonatomic) IBOutlet UIButton *selectionBtn;
- (IBAction)btnTapped:(id)sender;

@end
