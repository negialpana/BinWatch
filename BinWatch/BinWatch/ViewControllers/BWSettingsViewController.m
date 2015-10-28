//
//  BWSettingsViewController.m
//  BinWatch
//
//  Created by Supritha Nagesha on 23/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWSettingsViewController.h"
#import "BWAppSettings.h"

@interface BWSettingsViewController ()<UITextFieldDelegate>
- (IBAction)switchOnOffChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *radiusTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailtextField;
@property (weak, nonatomic) IBOutlet UISwitch *excelSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *csvSwitch;
- (IBAction)donePressed:(id)sender;

@property (weak, nonatomic) IBOutlet UISwitch *pdfSwitch;
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

- (void)viewWillAppear:(BOOL)animated{
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    self.radiusTextField.text = [ud valueForKey:kCoverageRadius]?[[ud valueForKey:kCoverageRadius] stringValue]:[NSString stringWithFormat:@"%d",DEFAULT_RADIUS];
    self.pdfSwitch.on = [[BWAppSettings sharedInstance] getExportPDF];
    self.excelSwitch.on = [[BWAppSettings sharedInstance] getExportExcel];
    self.csvSwitch.on = [[BWAppSettings sharedInstance] getExportCSV];
    self.emailtextField.text = [ud valueForKey:kSupportMailID];
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
            textField.text = [NSString stringWithFormat:@"%d",DEFAULT_RADIUS];
        }
        [userDefaults setValue:[NSNumber numberWithInt:[textField.text intValue]] forKey:kCoverageRadius];
        
    }else{
        
        if (![textField.text length]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                            message:@"Please enter mailID"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return NO;
            
        }else{
            [userDefaults setValue:textField.text forKey:kSupportMailID];

        }
    
    }
    [userDefaults synchronize];
    [textField endEditing:YES];
    
    return YES;
}


- (IBAction)switchOnOffChanged:(id)sender {
    
    UISwitch *swith = (UISwitch *)sender;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    switch (swith.tag) {
        case 1:
        {
            [[BWAppSettings sharedInstance] saveExportPDF:swith.on];
        }
            break;
        case 2:
        {
            [[BWAppSettings sharedInstance] saveExportExcel:swith.on];
        }
            break;
        case 3:
        {
            [[BWAppSettings sharedInstance] saveExportCSV:swith.on];
        }
            break;
        default:
            break;
    }
    
    [userDefaults synchronize];
}

- (IBAction)donePressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
