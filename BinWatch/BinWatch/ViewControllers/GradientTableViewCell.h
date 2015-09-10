//
//  GradientTableViewCell.h
//  BinWatch
//
//  Created by Ponnie Rohith on 10/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWCommon.h"

@interface GradientTableViewCell : UITableViewCell

-(instancetype)initWithColor:(BWBinColor)color reuseIdentifier:(NSString *)reuseIdentifier;

@end
