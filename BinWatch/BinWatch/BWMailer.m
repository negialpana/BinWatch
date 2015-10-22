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
#import <MessageUI/MFMailComposeViewController.h>

@implementation BWMailer

-(void) sendMail:(UIViewController *)viewController
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = viewController;
        [controller setSubject:@"My Subject"];
        [controller setMessageBody:@"Hello there." isHTML:NO];
        if (controller)
        {
            [viewController presentViewController:controller animated:YES completion:nil];
        }
    }
    else
    {
        // Handle the error
        [BWLogger DoLog:@"Mail not configured"];
        [BWHelpers displayHud:@"Mail not configured" onView:viewController.view];
    }
}

@end
