//
//  LoginHandler.h
//  BinWatch
//
//  Created by Ponnie Rohith on 28/11/15.
//  Copyright © 2015 Airwatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginHandler : NSObject

-(void)showLoginAlert;
+(BOOL)loginWithUsername:(NSString*)username andPassword:(NSString*)password;

@end
