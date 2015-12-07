//
//  LoginHandler.m
//  BinWatch
//
//  Created by Ponnie Rohith on 28/11/15.
//  Copyright © 2015 Airwatch. All rights reserved.
//

#import "LoginHandler.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "BWAppSettings.h"

@interface LoginHandler () <UITextFieldDelegate>
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

@end


@implementation LoginHandler

-(void)showLoginAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login Required"
                                                                   message:@"Switching to BBMP Mode requires you to login"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancelButtonAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:nil];
    UIAlertAction* loginButtonAction = [UIAlertAction actionWithTitle:@"Login"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){
                                                                  self.username = [(UITextField*)alert.textFields[0] text];
                                                                  self.password = [(UITextField*)alert.textFields[0] text];
                                                                  //[self loginWithUsername:self.username andPassword:self.password];
                                                              }];
    [alert addAction:cancelButtonAction];
    [alert addAction:loginButtonAction];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"User name";
        textField.delegate = self;
        textField.tag = 0;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.delegate = self;
        textField.tag = 1;
    }];
    UIViewController *controllerToShowTo = [[AppDelegate appDel] getTabBarContoller];
    [controllerToShowTo presentViewController:alert animated:YES completion:nil];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 0) {
        self.username = textField.text;
    }
    if (textField.tag == 1) {
        self.password = textField.text;
    }
}
+(BOOL)loginWithUsername:(NSString*)username andPassword:(NSString*)password
{
    PFUser *user = [PFUser logInWithUsername:username password:password];
    if (user) {
        [[BWAppSettings sharedInstance] saveAppMode:BWBBMPMode];
        [[AppDelegate appDel] switchToMainStoryBoard];
    }
//    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
//        if (user) {
//            // Do stuff after successful login.
//            //[self fetchHotelIdFromUserId:[user objectId]];
//            return YES;
//        } else {
//            // The login failed. Check error to see why.
//            return NO;
////            [self lockAnimationForView:self.password];
//            
//        }
//    }];
//
    return NO;
}

@end
