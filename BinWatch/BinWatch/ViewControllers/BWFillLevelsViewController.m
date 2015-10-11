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
#import "AppDelegate.h"

#import "MBProgressHUD.h"

#define NoBinsFont [UIFont fontWithName:@"Palatino-Italic" size:20]
const NSString *noBinsMessage = @"No data is currently available. Please pull down to refresh.";

@interface BWFillLevelsViewController () <UITableViewDataSource , UITableViewDelegate , UISearchBarDelegate , MBProgressHUDDelegate >

@property NSMutableArray *searchArray;
@end

@implementation BWFillLevelsViewController

bool searching = NO;
bool noBins = NO;
NSMutableArray *activeBins;
UIRefreshControl *refreshControl;

#pragma  mark - View Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    activeBins = [[NSMutableArray alloc]init];

    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.delegate = self;
    HUD.labelText = @"Loading";
    
    [HUD showWhileExecuting:@selector(fetchData) onTarget:self withObject:nil animated:YES];

    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"more_dashes"] style:UIBarButtonItemStyleDone target:self action:@selector(moreTapped)];
    self.navigationItem.rightBarButtonItem = moreButton;

    [self refreshBins];


    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(didChangeDeviceOrientation)
               name:UIDeviceOrientationDidChangeNotification
             object:nil];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(fetchData)
             forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:refreshControl];

}

-(void)fetchData
{
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
            if (![[AppDelegate appDel] connected]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Connected"
                                                                message:@"You're not connected to the internet."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];

            }
            
        }
    }];

}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (noBins) {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = noBinsMessage;
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = NoBinsFont;
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    }
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
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld%%",[bin.fill longValue]];
        
    cell.textLabel.textColor = [BWHelpers textColorForBinColor:bin.color];
    cell.detailTextLabel.textColor = [BWHelpers textColorForBinColor:bin.color];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BWBin *bin = [self binForRowAtIndexPath:indexPath];
    GradientView *gradientView = [[GradientView alloc]initWithFrame:cell.frame forfill:[bin.fill floatValue]];
    cell.backgroundView = gradientView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    BinDetailsViewController *binDetailsVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"BinDetailsViewController"];
    binDetailsVC.currentSelectedBinIndex = (int)indexPath.row;
    
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
    noBins = activeBins.count ? NO : YES;
    [self.tableView reloadData];
    
    if (refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        refreshControl.attributedTitle = attributedTitle;
        
        [refreshControl endRefreshing];
    }

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
