//
//  BWExportTableViewController.m
//  BinWatch
//
//  Created by Supritha Nagesha on 25/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWExportTableViewController.h"
#import "BWAppSettings.h"
#import "BWViewRenderingHelper.h"

#define BAR_VIEW_WIDTH_WITH_SPACING     43.0f
#define CIRCLE_VIEW_TAG_START_VAL       100
#define MAX_GRAPHS_TO_BE_RENDERED       7

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

    [self setUpBarGraphViews];
    [self setUpTemperatureGraph];
    [self joinCirclesWithLine];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)setUpBarGraphViews
{
    for (int i = 0; i < MAX_GRAPHS_TO_BE_RENDERED; i++) {
        CGRect barGraphViewFrame = _blackLine.frame;
        
        //todo : dummy fill level. Get fill levels from server
        float fillLevel = 20 + (arc4random() % 80);
        [BWViewRenderingHelper addBarGraphOnView:_exportView atOrigin:CGPointMake(10.0f + (BAR_VIEW_WIDTH_WITH_SPACING * i), barGraphViewFrame.origin.y) withFillLevel:fillLevel];
    }
}

- (void)setUpTemperatureGraph
{
    for (int i = 0; i < MAX_GRAPHS_TO_BE_RENDERED; i++) {
        CGRect barGraphViewFrame = _blackLine.frame;
        
        //todo : dummy temperature details. Get temperature details from server
        [BWViewRenderingHelper addCircleOnView:_exportView atOrigin:CGPointMake(17+(BAR_VIEW_WIDTH_WITH_SPACING * i), barGraphViewFrame.origin.y - 20 - arc4random()%85) andTag:CIRCLE_VIEW_TAG_START_VAL+i];
    }
}

- (void)joinCirclesWithLine
{
    for (int i = 0; i < MAX_GRAPHS_TO_BE_RENDERED - 1; i++)
    {
        UIView *circleView1 = [_exportView viewWithTag:CIRCLE_VIEW_TAG_START_VAL+i];
        UIView *circleView2 = [_exportView viewWithTag:CIRCLE_VIEW_TAG_START_VAL+i+1];
        
        CGPoint circleCenter1 = CGPointMake(circleView1.frame.origin.x + circleView1.frame.size.width * 0.5f, circleView1.frame.origin.y + circleView1.frame.size.height * 0.5f);
        CGPoint circleCenter2 = CGPointMake(circleView2.frame.origin.x + circleView2.frame.size.width * 0.5f, circleView2.frame.origin.y + circleView2.frame.size.height * 0.5f);
        
        [BWViewRenderingHelper joinCircleCenters:circleCenter1 and:circleCenter2 onView:_exportView];
    }
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
