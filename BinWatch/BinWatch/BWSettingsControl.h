//
//  BWSettingsControl.h
//  TableViewMore
//
//  Created by Seema Kadavan on 10/11/15.
//  Copyright (c) 2015 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol BWSettingsControlDelegate <NSObject>

- (void)didTapSettingsRow:(NSInteger)row;

@end

@interface BWSettingsControl : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id<BWSettingsControlDelegate> delegate;

- (void) createControl: (UIView *)parent withCells:(NSArray *)cells andFrame:(CGRect) frame;
- (void) hideControl;
- (void) toggleControl;

@end
