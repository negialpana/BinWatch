//
//  BWExportTableViewController.m
//  BinWatch
//
//  Created by Supritha Nagesha on 25/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWExportTableViewController.h"
#import "BWAppSettings.h"

@interface BWExportTableViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *fileView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UISwitch *pdfSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *excelSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *csv;
- (IBAction)switchIsOnOff:(id)sender;
- (IBAction)donePressed:(id)sender;

@end

@implementation BWExportTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emailTextField.text = [[BWAppSettings  sharedInstance] getSupportMailID];
    self.pdfSwitch.on = [[BWAppSettings sharedInstance] getExportPDF];
    self.excelSwitch.on = [[BWAppSettings sharedInstance] getExportExcel];
    self.csv.on = [[BWAppSettings sharedInstance] getExportCSV];
    
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

- (IBAction)switchIsOnOff:(id)sender {
    
    UISwitch *swith = (UISwitch *)sender;
    if (swith == self.pdfSwitch) {
        [[BWAppSettings sharedInstance] saveExportPDF:swith.on];
    }else if (swith == self.excelSwitch){
        [[BWAppSettings sharedInstance] saveExportExcel:swith.on];
    }else {
        [[BWAppSettings sharedInstance] saveExportCSV:swith.on];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    [[BWAppSettings sharedInstance] saveSupportMailID:textField.text];
}

- (IBAction)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
