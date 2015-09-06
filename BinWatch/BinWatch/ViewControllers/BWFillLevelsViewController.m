//
//  BWFillLevelsViewController.m
//  BinWatch
//
//  Created by Supritha Nagesha on 03/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWFillLevelsViewController.h"
#import "ConnectionHandler.h"
#import "DataHandler.h"

@interface BWFillLevelsViewController ()

@end

@implementation BWFillLevelsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ConnectionHandler *connectionHandler = [ConnectionHandler sharedInstance];
    [connectionHandler getBinsWithCompletionHandler:^(NSArray * bins, NSError *error) {
        
        if (!error) {
            
            NSLog(@"*********Bins: %@",[bins description]);
            DataHandler *dataHandler = [DataHandler sharedHandler];
            [dataHandler insertBins:bins];
        }else{
            NSLog(@"***********Failed to get bins***************");
        }
    }];
    // Do any additional setup after loading the view.
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
