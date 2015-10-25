//
//  BWAppSettings.m
//  BinWatch
//
//  Created by Seema Kadavan on 10/11/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWAppSettings.h"
#import "AppDelegate.h"
#import "BWHelpers.h"
#import "BWMailer.h"
#import "BWSettingsViewController.h"

@implementation BWAppSettings

static NSString* const kDefaultMailID = @"BinWatch.ReapBenefit@gmail.com";

+ (BWAppSettings *)sharedInstance
{
    static dispatch_once_t onceToken;
    static BWAppSettings *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BWAppSettings alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self saveUserDefaults];
    }
    return self;
}


-(void)saveUserDefaults
{
    // Saving default Data to user defaults
    NSString *mailID = [self getSupportMailID];
    if(!mailID)
    {
        // App launching for first time
        [self saveSupportMailID:kDefaultMailID];
        [self saveCoverageRadius:DEFAULT_RADIUS];
        [self saveExportCSV:YES];
        [self saveExportExcel:YES];
        [self saveExportPDF:YES];
        // TODO: This has to be changed
        [self saveAppMode:BWBBMPMode];
    }
 
}

-(void)switchedAppMode{
    BWAppMode appMode = [self getAppMode];
    switch (appMode) {
        case BWUserMode:
            [self saveAppMode:BWBBMPMode];
            [[AppDelegate appDel] switchToMainStoryBoard];
            break;
        case BWBBMPMode:
            [self saveAppMode:BWUserMode];
            [[AppDelegate appDel] switchToUserModeStoryBoard];
            break;
            
        default:
            [self saveAppMode:BWUserMode];
            [[AppDelegate appDel] switchToUserModeStoryBoard];
            break;
    }
}
-(void)switchedToBBMPMode{
    NSLog(@"switchedToBBMPMode notif");
    
}
-(void)exportSelected{
    NSLog(@"exportSelected notif");
    
}
-(void)settingsSelected{
    NSLog(@"settingsSelected notif");
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    BWSettingsViewController *sv = [sb instantiateViewControllerWithIdentifier:@"settingsNavigation"];
    UIViewController *controllerToShowTo = [[AppDelegate appDel] getTabBarContoller];

    [controllerToShowTo presentViewController:sv animated:YES completion:nil];
    
}
-(void)requestBinSelected
{
    NSString *mailContent = [NSString stringWithFormat:@"%@\n\nLocation: %@\nLatitude: %f\nLongitude: %f", kRequestBinEmailBody, [BWDataHandler sharedHandler].myLocationAddress, [BWDataHandler sharedHandler].myLocation.coordinate.latitude, [BWDataHandler sharedHandler].myLocation.coordinate.longitude];
    [BWMailer composeMailWithSubject:kRequestBinEmailSubject andBody:mailContent];
}

-(void)reportBinSelected
{
    [BWMailer composeMailWithSubject:kReportBinEmailSubject andBody:kReportBinEmailBody];
 
}
-(void)reportIssueSelected
{
    [BWMailer composeMailWithSubject:kReportIssueEmailSubject andBody:kReportIssueEmailBody];

}
#pragma mark - Settings getters and setters

-(void) saveAppMode:(BWAppMode)mode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithInt:mode] forKey:kAppMode];
}

-(BWAppMode) getAppMode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults valueForKey:kAppMode] integerValue];
}

-(void) saveSupportMailID:(NSString *)mailID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:mailID forKey:kSupportMailID];
}

-(NSString *) getSupportMailID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:kSupportMailID];
}

-(void) saveCoverageRadius:(int)radius
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithInt:radius] forKey:kCoverageRadius];
}

-(int) getCoverageRadius
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return (int)[[defaults valueForKey:kCoverageRadius] integerValue];
}

-(void) saveExportPDF:(bool)enable
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithBool:enable] forKey:kExportPDFOn];
}

-(bool) getExportPDF
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults valueForKey:kExportPDFOn] boolValue];
}

-(void) saveExportExcel:(bool)enable
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithBool:enable] forKey:kExportExcelOn];
}

-(bool) getExportExcel
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults valueForKey:kExportExcelOn] boolValue];
}

-(void) saveExportCSV:(bool)enable
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSNumber numberWithBool:enable] forKey:kExportCSVOn];
}

-(bool) getExportCSV
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults valueForKey:kExportCSVOn] boolValue];
}

@end
