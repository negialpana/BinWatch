//
//  BWMailer.m
//  BinWatch
//
//  Created by Seema Kadavan on 10/18/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWMailer.h"
#import "BWLogger.h"
#import "BWHelpers.h"
#import "AppDelegate.h"
#import "BWAppSettings.h"

@implementation BWMailer

+ (BWMailer *)sharedInstance
{
    static dispatch_once_t onceToken;
    static BWMailer *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BWMailer alloc] init];
    });
    
    return instance;
}

+(void) composeMailWithSubject:(NSString*)subject andBody:(NSString*)body
{
    UIViewController *controllerToShowTo = [[AppDelegate appDel] getTabBarContoller];
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = [self sharedInstance];
        [controller setSubject:subject];
        [controller setMessageBody:body isHTML:NO];
        [controller setToRecipients:@[[[BWAppSettings sharedInstance] getSupportMailID]]];
        if (controller)
        {
            [controllerToShowTo presentViewController:controller animated:YES completion:nil];
        }
    }
    else
    {
        // Handle the error
        [BWLogger DoLog:@"Mail not configured"];
        [BWHelpers displayHud:@"Mail not configured" onView:controllerToShowTo.view];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIViewController *controllerToShowTo = [[AppDelegate appDel] getTabBarContoller];
    NSString *message;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            message = @"Email Cancelled";
            break;
        case MFMailComposeResultSaved:
            message = @"Email Saved";
            break;
        case MFMailComposeResultSent:
            message = @"Email Sent";
            break;
        case MFMailComposeResultFailed:
            message = @"Email Failed";
            break;
        default:
            message = @"Email Not Sent";
            break;
    }
    runOnMainThread(^{
        [BWHelpers displayHud:message onView:controllerToShowTo.view];
    });
    
    [controllerToShowTo dismissViewControllerAnimated:YES completion:nil];
}


@end
