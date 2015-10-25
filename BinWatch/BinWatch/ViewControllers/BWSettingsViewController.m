//
//  BWSettingsViewController.m
//  BinWatch
//
//  Created by Supritha Nagesha on 23/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWSettingsViewController.h"

@interface BWSettingsViewController ()<UITextFieldDelegate>
- (IBAction)switchOnOffChanged:(id)sender;

@end

@implementation BWSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *gesRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOutSide:)];
    [gesRec setNumberOfTapsRequired:1];
    [self.tableView addGestureRecognizer:gesRec];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)tappedOutSide:(id)sender{
    
    if (![sender isKindOfClass:[UITextField class]]) {
        [self.view endEditing:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (textField.tag == 100) {
        
        if (![textField.text length]) {
            textField.text = @"5";
        }
        [userDefaults setValue:[NSNumber numberWithInt:[textField.text intValue]] forKey:@"RADIUS"];
        
    }else{
        
        if (![textField.text length]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Please enter mailID" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return NO;
            
        }else{
            [userDefaults setValue:textField.text forKey:@"EMAIL"];

        }
    
    }
    [userDefaults synchronize];
    [textField endEditing:YES];
    
    return YES;
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    // Return the number of sections.
//    return 3;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    // Return the number of rows in the section.
//    
//    if (section == 1)
//        return 3;
//    return 1;
//}
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)switchOnOffChanged:(id)sender {
    
    UISwitch *swith = (UISwitch *)sender;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    switch (swith.tag) {
        case 1:
        {
            [userDefaults setBool:swith.isOn forKey:@"PDF"];
        }
            break;
        case 2:
        {
            [userDefaults setBool:swith.isOn forKey:@"EXCEL"];

        }
            break;
        case 3:
        {
            [userDefaults setBool:swith.isOn forKey:@"CSV"];
        }
            break;
        default:
            break;
    }
    
    [userDefaults synchronize];
}
@end
