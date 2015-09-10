//
//  BWFillLevelsViewController.m
//  BinWatch
//
//  Created by Supritha Nagesha on 03/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWFillLevelsViewController.h"
#import "DataHandler.h"
#import "BWHelpers.h"
#import "BWBin.h"
#import "BWCommon.h"
#import "GradientView.h"


@interface BWFillLevelsViewController () <UITableViewDataSource , UITableViewDelegate , UISearchBarDelegate >

@property NSArray *binsArray;
@property NSMutableArray *searchArray;
@end

@implementation BWFillLevelsViewController

bool searching = NO;
NSArray *placesArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    placesArray = @[@"Hope farm",@"PSN" ,@"Hoodi" ,@"KRPuram", @"Mahadevapura",@"BTM",@"Agara",@"Whitefield"];
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"more_dashes"] style:UIBarButtonItemStyleDone target:self action:@selector(moreTapped)];
    self.navigationItem.rightBarButtonItem = moreButton;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    DataHandler *dataHandler = [DataHandler sharedInstance];
    [dataHandler getBinsWithCompletionHandler:^(NSArray * bins, NSError *error) {
        if (!error) {
            NSLog(@"*********Bins: %@",[bins description]);
            self.binsArray = [BWHelpers binsArrayFromJSonArray:bins];
            [self.tableView reloadData];
            
        }else{
            NSLog(@"***********Failed to get bins***************");
        }
    }];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (searching) {
        return self.searchArray.count;
    }
    return self.binsArray.count;
//    return 25;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"CellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }

    BWBin *bin = [self binForRowAtIndexPath:indexPath];
    NSString *location;
    if (indexPath.row >= placesArray.count) {
        location = [NSString stringWithFormat:@"Location %ld",(long)indexPath.row];
    }
    else{
        location = placesArray[indexPath.row];
    }

    cell.textLabel.text = location;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d%%",(int)bin.fillPercent];
    cell.detailTextLabel.textColor = Black;
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BWBin *bin = [self binForRowAtIndexPath:indexPath];
    GradientView *gradientView = [[GradientView alloc]initWithFrame:cell.frame forColor:bin.color];
    cell.backgroundView = gradientView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
        for (BWBin *bin in self.binsArray) {
            if ([searchText isEqualToString:placesArray[i]]) {
                [self.searchArray addObject:bin];
            }
            i++;
        }
    }
    [self.tableView reloadData];

}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searching = NO;
    [self.tableView reloadData];

}

- (void)moreTapped
{
    NSLog(@"More tapped");
}
-(BWBin*)binForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BWBin *bin;
    if (searching) {
        bin = (BWBin*)[self.searchArray objectAtIndex:indexPath.row];
    }
    else{
        if (indexPath.row >= self.binsArray.count) {
            bin = [[BWBin alloc]initWith:10.00 longitude:10.00 binColor:BWRed fillPercent:99];
        }
        else{
            
            bin = (BWBin*)[self.binsArray objectAtIndex:indexPath.row];
        }
    }
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
