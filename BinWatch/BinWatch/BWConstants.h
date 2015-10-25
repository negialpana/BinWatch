//
//  BWConstants.h
//  BinWatch
//
//  Created by Ponnie Rohith on 12/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWLogger.h"

@interface BWConstants : NSObject

extern NSString* const kGoogleAPIKey;
extern NSString* const kGoogleAPIKey_Browser;

extern NSString* const kBinDataChangedNotification;

#define RED_BOUNDARY 70
#define YELLOW_BOUNDARY 50
#define DEFAULT_RADIUS 5

#define RedColor    [UIColor colorWithRed:188.0/255.0f green:33.0/255.0f blue:33.0/255.0f alpha:1.0]
#define GreenColor  [UIColor colorWithRed:56.0/255.0f green:139.0/255.0f blue:59.0/255.0f alpha:1.0]
#define YellowColor [UIColor colorWithRed:255.0/255.0f green:152.0/255.0f blue:0.0/255.0f alpha:1.0]

#define DarkRed     [UIColor colorWithRed:113.0/255.0f green:3.0/255.0f blue:3.0/255.0f alpha:1.0]
#define DarkYellow  [UIColor colorWithRed:181.0/255.0f green:135.0/255.0f blue:22.0/255.0f alpha:1.0]
#define DarkGreen   [UIColor colorWithRed:15.0/255.0f green:77.0/255.0f blue:19.0/255.0f alpha:1.0]

#define LightRed    [UIColor colorWithRed:186.0/255.0f green:17.0/255.0f blue:9.0/255.0f alpha:1.0]
#define LightYellow [UIColor colorWithRed:211.0/255.0f green:178.0/255.0f blue:28.0/255.0f alpha:1.0]
#define LightGreen  [UIColor colorWithRed:16.0/255.0f green:120.0/255.0f blue:32.0/255.0f alpha:1.0]

#define AppTheme    [UIColor colorWithRed:21.0/255.0f green:149.0/255.0f blue:238.0/255.0f alpha:1.0]

#define Black       [UIColor blackColor]
#define White       [UIColor whiteColor]
#define Gray        [UIColor grayColor]

extern NSString* const kNotConnectedTitle ;
extern NSString* const kNotConnectedText  ;
extern NSString* const kConnectedTitle ;
extern NSString* const kConnectedText  ;

extern NSString* const kSwitchToUser     ;
extern NSString* const kSwitchToBBMP     ;
extern NSString* const kExport           ;
extern NSString* const kSettings         ;
extern NSString* const kReportAnIssue    ;
extern NSString* const kRequestForBin    ;
extern NSString* const kReportBin        ;
extern NSString* const kRouteToNearest   ;
extern NSString* const kRouteToRed       ;
extern NSString* const kRouteToRedYellow ;
extern NSString* const kRouteToSelected  ;

extern NSString* const kSearchPlaceHolder           ; 
extern NSString* const kRouteFetchFailed            ; 
extern NSString* const kCurrentLocationFailed       ; 
extern NSString* const kPlacesFetchFailed           ; 
extern NSString* const kSelectedPlaceFetchFailed    ;
extern NSString* const kBinFetchFailed              ;
extern NSString* const kNoSelectedBins              ;

extern NSString* const kRequestBinEmailSubject  ;
extern NSString* const kRequestBinEmailBody     ;
extern NSString* const kReportBinEmailSubject   ;
extern NSString* const kReportBinEmailBody      ;
extern NSString* const kReportIssueEmailSubject ;
extern NSString* const kReportIssueEmailBody    ;


extern NSString* const kIcon         ; 
extern NSString* const kUserData     ; 

extern NSString* const kYellow       ; 
extern NSString* const kGreen        ; 
extern NSString* const kRed          ; 

extern NSString* const kTrashYellow  ;
extern NSString* const kTrashGreen   ; 
extern NSString* const kTrashRed     ;

extern NSString* const kTrashPickerYellow  ; 
extern NSString* const kTrashPickerGreen   ; 
extern NSString* const kTrashPickerRed     ;


extern NSString* const kMoreButtonImageName ;


typedef NS_ENUM(NSUInteger, BWBinColor) {
    BWRed,
    BWGreen,
    BWYellow,
};

#define SHOWALERT(Title, Text)                                                 \
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Title                \
                                                  message:Text                 \
                                                 delegate:self                 \
                                        cancelButtonTitle:@"OK"                \
                                        otherButtonTitles:nil];                \
  [alert show];

@end
