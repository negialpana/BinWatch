//
//  BWFillLevelsViewController.m
//  BinWatch
//
//  Created by Supritha Nagesha on 03/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWFillLevelsViewController.h"
#import "DataHandler.h"
#import "ObjectParser.h"
#import "BWBin.h"
@interface BWFillLevelsViewController () <UITableViewDataSource , UITableViewDelegate , UISearchBarDelegate >

@property NSInteger noOfBins;
@property NSArray *binsArray;
@end

@implementation BWFillLevelsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DataHandler *dataHandler = [DataHandler sharedInstance];
    [dataHandler getBinsWithCompletionHandler:^(NSArray * bins, NSError *error) {
        if (!error) {
            NSLog(@"*********Bins: %@",[bins description]);
            self.binsArray = [ObjectParser binsArrayFromJSonArray:bins];
            self.noOfBins = bins.count;
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
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"CellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }

    BWBin *bin = (BWBin*)[self.binsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Location %ld",(long)indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f",bin.fillPercent];
    UIColor *backgroundColor;
    switch (bin.color) {
        case BWGreen:
            backgroundColor = [UIColor greenColor];
            break;
        case BWYellow:
            backgroundColor = [UIColor yellowColor];
            break;
        case BWRed:
            backgroundColor = [UIColor redColor];
            break;
            
        default:
            backgroundColor = [UIColor greenColor];
            break;
    }
    cell.backgroundColor = backgroundColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
