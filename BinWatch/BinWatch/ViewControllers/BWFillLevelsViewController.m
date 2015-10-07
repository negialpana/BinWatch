//
//  BWFillLevelsViewController.m
//  BinWatch
//
//  Created by Supritha Nagesha on 03/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWFillLevelsViewController.h"
#import "BWConnectionHandler.h"
#import "BWDataHandler.h"
#import "BWHelpers.h"
#import "BWBin.h"
#import "BWCommon.h"
#import "GradientView.h"
#import "BinDetailsViewController.h"

@interface BWFillLevelsViewController () <UITableViewDataSource , UITableViewDelegate , UISearchBarDelegate >

@property NSMutableArray *searchArray;
@end

@implementation BWFillLevelsViewController

bool searching = NO;
NSMutableArray *activeBins;

#pragma  mark - View Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    activeBins = [[NSMutableArray alloc]init];

    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"more_dashes"] style:UIBarButtonItemStyleDone target:self action:@selector(moreTapped)];
    self.navigationItem.rightBarButtonItem = moreButton;

    [self refreshBins];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    BWConnectionHandler *connectionHandler = [BWConnectionHandler sharedInstance];
    [connectionHandler getBinsWithCompletionHandler:^(NSArray * bins, NSError *error) {
        if (!error)
        {
            NSLog(@"*********Bins: %@",[bins description]);
            [[BWDataHandler sharedHandler] insertBins:bins];
            [self refreshBins];
        }else
        {
            NSLog(@"***********Failed to get bins***************");
        }
    }];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(didChangeDeviceOrientation)
               name:UIDeviceOrientationDidChangeNotification
             object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (searching) {
        return self.searchArray.count;
    }
    return activeBins.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"CellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }

    BWBin *bin = [self binForRowAtIndexPath:indexPath];
    cell.textLabel.text = [BWHelpers areanameFromFullAddress:bin.place];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d%%",[bin.fill integerValue]];
        
    cell.textLabel.textColor = [BWHelpers textColorForBinColor:bin.color];
    cell.detailTextLabel.textColor = [BWHelpers textColorForBinColor:bin.color];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BWBin *bin = [self binForRowAtIndexPath:indexPath];
    GradientView *gradientView = [[GradientView alloc]initWithFrame:cell.frame forColor:bin.color];
    cell.backgroundView = gradientView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    BinDetailsViewController *binDetailsVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"BinDetailsViewController"];
    binDetailsVC.currentSelectedBinIndex = indexPath.row;
    
    [self.navigationController pushViewController:binDetailsVC animated:YES];
}

#pragma  mark - UISearchBar Delegates
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searching = NO;
    [self.tableView reloadData];
 
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searching = NO;
    [self.tableView reloadData];
  
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchText = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (searchText.length == 0) {
        searching = NO;
    }
    else{
        searching = YES;
        self.searchArray = [NSMutableArray new];
        int i = 0;
        // TODO: This has to be based on new bin request
        for (BWBin *bin in activeBins) {
//            if ([searchText isEqualToString:placesArray[i]]) {
//                [self.searchArray addObject:bin];
//            }
            i++;
        }
    }
    [self.tableView reloadData];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searching = NO;
    if ([self.searchBar canResignFirstResponder]) {
        [self.searchBar resignFirstResponder];

    }
    [self.tableView reloadData];
}

#pragma mark - Event Handlers
- (void)moreTapped
{
    NSLog(@"More tapped");
}

-(void)didChangeDeviceOrientation
{
    [self.tableView reloadData];
}
#pragma mark - Utility Methods
- (void) refreshBins
{
    activeBins = [[[BWDataHandler sharedHandler] fetchBins] mutableCopy];
    NSLog(@"existingBins: %lu", (unsigned long)activeBins.count);
    [self.tableView reloadData];
}

-(BWBin*)binForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BWBin *bin;
    if (searching)
      bin = (BWBin *)[self.searchArray objectAtIndex:indexPath.row];
    else
      bin = (BWBin *)[activeBins objectAtIndex:indexPath.row];
    return bin;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
