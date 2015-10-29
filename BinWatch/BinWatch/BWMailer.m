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
#import "BWDocumentHelper.h"

#define FILE_NAME_CSV @"BinWatch.csv"
#define FILE_NAME_PDF @"BinWatch.pdf"
#define FILE_NAME_XLS @"BinWatch.xls"

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

+(void) composeMailWithSubject:(NSString*)subject body:(NSString*)body andAttachment:(NSArray*)files
{
    UIViewController *controllerToShowTo = [[AppDelegate appDel] getTabBarContoller];

    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = [self sharedInstance];
        [controller setSubject:subject];
        [controller setMessageBody:body isHTML:NO];
        [controller setToRecipients:@[[[BWAppSettings sharedInstance] getSupportMailID]]];

        for(NSString *filePath in files)
        {
            // Determine the file name and extension
            NSString *filename = [filePath lastPathComponent];
            NSString *extension = [filename pathExtension];
            
            // Get the resource path and read the file using NSData
            NSData *fileData = [NSData dataWithContentsOfFile:filePath];
            
            // Determine the MIME type
            NSString *mimeType;
            if ([extension isEqualToString:@"jpg"]) {
                mimeType = @"image/jpeg";
            } else if ([extension isEqualToString:@"png"]) {
                mimeType = @"image/png";
            } else if ([extension isEqualToString:@"doc"]) {
                mimeType = @"application/msword";
            } else if ([extension isEqualToString:@"ppt"]) {
                mimeType = @"application/vnd.ms-powerpoint";
            } else if ([extension isEqualToString:@"html"]) {
                mimeType = @"text/html";
            } else if ([extension isEqualToString:@"pdf"]) {
                mimeType = @"application/pdf";
            } else if ([extension isEqualToString:@"xls"]) {
                mimeType = @"application/vnd.ms-excel";
            }
            
             if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
                 [controller addAttachmentData:fileData mimeType:mimeType fileName:filename];
        }

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

+(void)showCamera
{
    UIViewController *controllerToShowTo = [[AppDelegate appDel] getTabBarContoller];
    [BWHelpers displayHud:@"Take the photo of the unpicked bin" onView:controllerToShowTo.view];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = [self sharedInstance];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = YES;
        
        [controllerToShowTo presentViewController:imagePicker animated:YES completion:nil];
    }else{
        SHOWALERT(@"Camera Unavailable", @"Unable to find a camera on your device.");
    }

}

#pragma mark - Mail composer delegates

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIViewController *controllerToShowTo = [[AppDelegate appDel] getTabBarContoller];
    NSString *message;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [[[BWDocumentHelper alloc]init] deleteAllFiles];
            message = @"Email Cancelled";
            break;
        case MFMailComposeResultSaved:
            message = @"Email Saved";
            break;
        case MFMailComposeResultSent:
            [[[BWDocumentHelper alloc]init] deleteAllFiles];
            message = @"Email Sent";
            break;
        case MFMailComposeResultFailed:
            [[[BWDocumentHelper alloc]init] deleteAllFiles];
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

#pragma mark - ImagePicker delegates

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *fileSavePath = [BWHelpers generateUniqueFilePath];
    fileSavePath = [fileSavePath stringByAppendingString:@".png"];
    
    //This checks to see if the image was edited, if it was it saves the edited version as a .png
    if ([info objectForKey:UIImagePickerControllerEditedImage]) {
        //save the edited image
        NSData *imgPngData = UIImagePNGRepresentation([info objectForKey:UIImagePickerControllerEditedImage]);
        [imgPngData writeToFile:fileSavePath atomically:YES];
    }else{
        //save the original image
        NSData *imgPngData = UIImagePNGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage]);
        [imgPngData writeToFile:fileSavePath atomically:YES];
    }

    UIViewController *controllerToShowTo = [[AppDelegate appDel] getTabBarContoller];
    [controllerToShowTo dismissViewControllerAnimated:YES completion:nil];
    
    [BWMailer composeMailWithSubject:kReportBinEmailSubject body:kReportBinEmailBody andAttachment:@[fileSavePath]];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    UIViewController *controllerToShowTo = [[AppDelegate appDel] getTabBarContoller];
    [controllerToShowTo dismissViewControllerAnimated:YES completion:nil];
    
    [BWMailer composeMailWithSubject:kReportBinEmailSubject andBody:kReportBinEmailBody];
}

@end
