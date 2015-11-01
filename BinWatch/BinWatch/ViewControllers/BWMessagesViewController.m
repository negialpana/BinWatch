//
//  BWMessagesViewController.m
//  BinWatch
//
//  Created by Ponnie Rohith on 26/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWMessagesViewController.h"
#import "ChatDialogViewCell.h"
#import "Message.h"
#import "BWSettingsControl.h"
#import "BWConstants.h"

@interface BWMessagesViewController ()
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, retain) BWSettingsControl *settingsControl;

@end

@implementation BWMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.messages = [NSArray arrayWithObjects:@"This is a message from BBMP.\nIf your bins are not being collected, please report.", @"This is a message from BBMP.\nPlease don't use the bin in front of PSN because it is faulty", @"This is a message from BinWatch.\nCheckout our new feature of request bin. You can now request a bin to BBMP using our menu item. \nThank you for your continued support", nil];
    
    // Navigation Bar Init
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:kMoreButtonImageName] style:UIBarButtonItemStyleDone target:self action:@selector(menuTapped)];
    self.navigationItem.rightBarButtonItem = menuButton;
    
    NSNumber *defaults;
    defaults   = [NSNumber numberWithInt:BWMenuItemAllUserDefaults];

    self.settingsControl = [[BWSettingsControl alloc] init];
    [self.settingsControl createMenuInViewController:self withCells:@[defaults] andWidth:200];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event Handlers
- (void)menuTapped
{
    [self.settingsControl toggleControl];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatDialogViewCell *cell;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"dialogCellId"];
    if (!cell) {
        cell = [[ChatDialogViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dialogCellId"];
    }
    Message *message = [[Message alloc]initWithText:self.messages[indexPath.row]];
    [cell configureCellWithMessage:message];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [[Message alloc]initWithText:self.messages[indexPath.row]];
    return [ChatDialogViewCell heightForCellWithMessage:message];
}


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

@end
