//
//  BWSettingsControl.m
//  TableViewMore
//
//  Created by Seema Kadavan on 10/11/15.
//  Copyright (c) 2015 AirWatch. All rights reserved.
//

#import "BWSettingsControl.h"
#import "BWConstants.h"
#import "BWAppSettings.h"

#define HEIGHT 300
#define MINWIDTH 100
#define ROWHEIGHT 44

@implementation BWSettingsControl 
{
    UITableView *settingsTableView;
    NSArray *settingsLabels;
    NSArray *settingsImages;
    CGFloat rowHeight;
}

-(CGRect)makeFrameForView:(UIView *)view withWidth:(CGFloat)width;
{
    if (width < MINWIDTH) {
        width = MINWIDTH;
    }
    float tableViewX = view.frame.origin.x - (width - view.frame.size.width);
    float tableViewY = view.frame.origin.y + 2 * view.frame.size.height;
    CGRect frame = CGRectMake(tableViewX, tableViewY, width, HEIGHT);
    return frame;
}

-(void)setImagesAndLabelsFromCells:(NSArray*)cells
{
    NSMutableArray *labels = [NSMutableArray new];
    NSMutableArray *images = [NSMutableArray new];
    NSString *switchTo;
    NSString *loginImage;
    if([[BWAppSettings sharedInstance] getAppMode] == BWBBMPMode){
        switchTo = kSwitchToUser;
        loginImage = kLogoutImageName;
    }
    else{
        switchTo = kSwitchToBBMP;
        loginImage = kLoginImageName;
    }
    
    for (NSNumber *cell in cells) {
        BWMenuItems menuItem = [cell integerValue];
        switch (menuItem) {
            case BWMenuItemDrawRoutes:
                [labels addObjectsFromArray:@[kRouteToRed, kRouteToRedYellow,kRouteToSelected]];
                [images addObjectsFromArray:@[kMapMarkerImageName,kMapMarkerImageName,kMapMarkerImageName]];
                break;
            case BWMenuItemRouteToNearest:
                [labels addObject:kRouteToNearest];
                [images addObject:kMapMarkerImageName];
                break;
            case BWMenuItemAllBBMPDefaults:
                [labels addObjectsFromArray:@[kRequestForBin,kReportAnIssue,kExport,kSettings,switchTo]];
                [images addObjectsFromArray:@[kEmailImageName,kEmailImageName,kExportImageName,kSettingsImageName,loginImage]];
                break;
            case BWMenuItemAllUserDefaults:
                [labels addObjectsFromArray:@[kRequestForBin,kReportAnIssue,kReportBin,switchTo]];
                [images addObjectsFromArray:@[kEmailImageName,kEmailImageName,kEmailImageName,loginImage]];
                break;
            case BWMenuItemExport:
                [labels addObject:kExport];
                [images addObject:kExportImageName];
                break;
            case BWMenuItemSettings:
                [labels addObject:kSettings];
                [images addObject:kSettingsImageName];
                break;
            case BWMenuItemSwitchMode:
                [labels addObject:switchTo];
                [images addObject:loginImage];
                break;
            case BWMenuItemReportBin:
                [labels addObject:kReportBin];
                [images addObject:kEmailImageName];
                break;
            case BWMenuItemReportIssue:
                [labels addObject:kReportAnIssue];
                [images addObject:kEmailImageName];
                break;
            case BWMenuItemRequestForBin:
                [labels addObject:kRequestForBin];
                [images addObject:kEmailImageName];
                break;
            default:
                break;
        }
    }
    settingsLabels = labels;
    settingsImages = images;
}
- (void) createMenuInViewController:(UIViewController *)vc withCells:(NSArray *)cells andWidth:(CGFloat)width{
    
    UIView *view = [vc.navigationItem.rightBarButtonItem valueForKey:@"view"];
    CGRect frame = [self makeFrameForView:view withWidth:width];
    [self createMenuInViewController:vc withCells:cells andFrame:frame];
    
}

- (void) createMenuInViewController:(UIViewController *)vc withCells:(NSArray *)cells andFrame:(CGRect)frame
{
    [self createControlInView:vc.navigationController.view withCells:cells andFrame:frame];
 
}

- (void) createControlInView:(UIView *)view withCells:(NSArray *)cells andWidth:(CGFloat)width;
{
    CGRect frame = [self makeFrameForView:view withWidth:width];
    [self createControlInView:view withCells:cells andFrame:frame];

}

- (void) createControlInView:(UIView *)view withCells:(NSArray *)cells andFrame:(CGRect)frame
{
    [self setImagesAndLabelsFromCells:cells];
    rowHeight = ROWHEIGHT;
    CGFloat height = settingsLabels.count * rowHeight;
    CGRect tableViewRect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height);
    settingsTableView = [[UITableView alloc] initWithFrame:tableViewRect
                                             style:UITableViewStylePlain];
    
    settingsTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    settingsTableView.delegate = self;
    settingsTableView.dataSource = self;
    [view addSubview:settingsTableView];
    settingsTableView.hidden = YES;
    
    // Ha .. Finally I got shadow up. Thanks StackOverflow
    // http://stackoverflow.com/questions/9012071/adding-drop-shadow-to-uitableview
    [settingsTableView.layer setShadowColor:[Black CGColor]];
    [settingsTableView.layer setShadowOffset:CGSizeMake(0, 0)];
    [settingsTableView.layer setShadowRadius:5.0];
    [settingsTableView.layer setShadowOpacity:1];
    settingsTableView.clipsToBounds = NO;
    settingsTableView.layer.masksToBounds = NO;

    [settingsTableView reloadData];
    [settingsTableView setSeparatorColor:[UIColor clearColor]];
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
    cell.imageView.image = [UIImage imageNamed:settingsImages[indexPath.row]];
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
    NSString *selectedOption = [settingsLabels objectAtIndex:indexPath.row];
    if ([selectedOption isEqualToString:kExport]) {
        [[BWAppSettings sharedInstance] exportSelected];
    }
    else if ([selectedOption isEqualToString:kSettings]) {
        [[BWAppSettings sharedInstance] settingsSelected];
    }
    else if ([selectedOption isEqualToString:kSwitchToBBMP] || [selectedOption isEqualToString:kSwitchToUser]) {
        [[BWAppSettings sharedInstance] switchedAppMode];
    }
    else if ([selectedOption isEqualToString:kReportAnIssue]) {
        [[BWAppSettings sharedInstance] reportIssueSelected];
    }
    else if ([selectedOption isEqualToString:kReportBin]) {
        [[BWAppSettings sharedInstance] reportBinSelected];
    }
    else if ([selectedOption isEqualToString:kRequestForBin]) {
        [[BWAppSettings sharedInstance] requestBinSelected];
    }
    else
    if ([self.delegate respondsToSelector:@selector(didTapSettingsRowWithText:)])
    {
        [self.delegate didTapSettingsRowWithText:selectedOption];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight; // the return height + your other view height
}

@end
