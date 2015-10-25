//
//  BWMailer.h
//  BinWatch
//
//  Created by Seema Kadavan on 10/18/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface BWMailer : NSObject <MFMailComposeViewControllerDelegate>

+(void) composeMailWithSubject:(NSString*)subject andBody:(NSString*)body;
@end
