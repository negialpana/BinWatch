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

- (void) createControlInView:(UIView *)view withCells:(NSArray *)cells andFrame:(CGRect)frame;
- (void) createControlInView:(UIView *)view withCells:(NSArray *)cells andWidth:(CGFloat)width;
- (void) createMenuInViewController:(UIViewController *)vc withCells:(NSArray *)cells andFrame:(CGRect)frame;
- (void) createMenuInViewController:(UIViewController *)vc withCells:(NSArray *)cells andWidth:(CGFloat)width;
- (void) hideControl;
- (void) toggleControl;

@end
