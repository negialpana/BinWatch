//
//  BWAppSettings.m
//  BinWatch
//
//  Created by Seema Kadavan on 10/11/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWAppSettings.h"
#import "AppDelegate.h"

@implementation BWAppSettings

NSString* const kSwitchedAppModeNotification    = @"SwitchedAppModeNotification";
NSString* const kExportSelectedNotification     = @"ExportSelectedNotification";
NSString* const kSettingsSelectedNotification   = @"SettingsSelectedNotification";

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
        [self registerNotifications];
    }
    return self;
}

-(void)registerNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(switchedAppMode) name:kSwitchedAppModeNotification object:nil];
    [center addObserver:self selector:@selector(exportSelected) name:kExportSelectedNotification object:nil];
    [center addObserver:self selector:@selector(settingsSelected) name:kSettingsSelectedNotification object:nil];
}

-(void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)switchedAppMode{
    switch (self.appMode) {
        case BWUserMode:
            self.appMode = BWBBMPMode;
            [[AppDelegate appDel] switchToMainStoryBoard];
            break;
        case BWBBMPMode:
            self.appMode = BWUserMode;
            [[AppDelegate appDel] switchToUserModeStoryBoard];
            break;
            
        default:
            self.appMode = BWUserMode;
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
    
}
@end
