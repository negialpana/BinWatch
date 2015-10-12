//
//  BWSettingsControl.m
//  TableViewMore
//
//  Created by Seema Kadavan on 10/11/15.
//  Copyright (c) 2015 AirWatch. All rights reserved.
//

#import "BWSettingsControl.h"
#import "BWConstants.h"

@implementation BWSettingsControl 
{
    UITableView *settingsTableView;
    NSArray *settingsLabels;
    CGFloat rowHeight;
}

- (void) createControl: (UIView *)parent withCells:(NSArray *)cellLabels andFrame:(CGRect) frame
{
    settingsLabels = cellLabels;
    rowHeight = 44;
    CGFloat height = cellLabels.count * rowHeight;
    CGRect tableViewRect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height);
    settingsTableView = [[UITableView alloc] initWithFrame:tableViewRect
                                             style:UITableViewStylePlain];
    
    settingsTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    settingsTableView.delegate = self;
    settingsTableView.dataSource = self;
    [parent addSubview:settingsTableView];
    settingsTableView.hidden = YES;
    
    // Ha .. Finally I got shadow up. Thanks StackOverflow
    // http://stackoverflow.com/questions/9012071/adding-drop-shadow-to-uitableview
    [settingsTableView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [settingsTableView.layer setShadowOffset:CGSizeMake(0, 0)];
    [settingsTableView.layer setShadowRadius:5.0];
    [settingsTableView.layer setShadowOpacity:1];
    settingsTableView.clipsToBounds = NO;
    settingsTableView.layer.masksToBounds = NO;

    [settingsTableView reloadData];
    [settingsTableView setSeparatorColor:[UIColor clearColor]];
    NSLog(@"HHH: %f", settingsTableView.rowHeight);
}

- (void) hideControl
{
    settingsTableView.hidden = YES;
}

- (void) toggleControl
{
    if(settingsTableView.hidden)
        settingsTableView.hidden = NO;
    else
        settingsTableView.hidden = YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.text = [settingsLabels objectAtIndex:indexPath.row];
    UIView *backgroundView = [[UIView alloc]init];
    //backgroundView.layer.backgroundColor = [[UIColor colorWithRed:0.529 green:0.808 blue:0.922 alpha:1]CGColor];
    backgroundView.layer.backgroundColor = [AppTheme CGColor];
    cell.selectedBackgroundView = backgroundView;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return settingsLabels.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    tableView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(didTapSettingsRow:)])
    {
        [self.delegate didTapSettingsRow:indexPath.row];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight; // the return height + your other view height
}

@end
