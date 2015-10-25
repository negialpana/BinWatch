//
//  BWConstants.m
//  BinWatch
//
//  Created by Ponnie Rohith on 12/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWConstants.h"

@implementation BWConstants

NSString* const kGoogleAPIKey            = @"AIzaSyBJZvhJsi6Dh1QQjkly_CZEn6WFyfRb6ew";
NSString* const kGoogleAPIKey_Browser    = @"AIzaSyCUbwYomfVufUiVTiDak2qvEHVKiwk2JUQ";

NSString* const kBinDataChangedNotification      = @"kBinDataChangedNotification";

NSString* const kNotConnectedTitle = @"Not Connected";
NSString* const kNotConnectedText  = @"You're not connected to the internet.";
NSString* const kConnectedTitle    = @"Connected";
NSString* const kConnectedText     = @"Connected to the internet.";

NSString* const kSwitchToUser     = @"Switch to User Mode";
NSString* const kSwitchToBBMP     = @"Switch to BBMP Mode";
NSString* const kExport           = @"Export";
NSString* const kSettings         = @"Settings";
NSString* const kReportAnIssue    = @"Report an issue";
NSString* const kRequestForBin    = @"Request For Bin";
NSString* const kReportBin        = @"Report bins not being picked up";
NSString* const kRouteToNearest   = @"Route to nearest bin";
NSString* const kRouteToRed       = @"Route to all Red bins";
NSString* const kRouteToRedYellow = @"Route to all Red/Yellow bins";
NSString* const kRouteToSelected    = @"Route to selected bins";

NSString* const kSearchPlaceHolder           = @"Search";
NSString* const kRouteFetchFailed            = @"Route fetch failed";
NSString* const kCurrentLocationFailed       = @"Couldn't read current location";
NSString* const kPlacesFetchFailed           = @"Couldn't fetch places";
NSString* const kSelectedPlaceFetchFailed    = @"Couldn't fetch selected location";
NSString* const kBinFetchFailed              = @"Couldn't fetch bins for selected location";
NSString* const kNoSelectedBins              = @"No bins are selected";

NSString* const kRequestBinEmailSubject  = @"Request For a New Bin";
NSString* const kRequestBinEmailBody     = @"BinWatch,\n\n\t I would like to have a new bin at my location.";
NSString* const kReportBinEmailSubject   = @"Report a bin not picked up";
NSString* const kReportBinEmailBody      = @"BinWatch,\n\t A bin at my location is not being picked up.Kindly inform the responsible authorities.";
NSString* const kReportIssueEmailSubject = @"Issue in BinWatch";
NSString* const kReportIssueEmailBody    = @"<Type in your message>";


NSString* const kIcon         = @"icon";
NSString* const kUserData     = @"userData";

NSString* const kYellow       = @"YELLOW";
NSString* const kGreen        = @"GREEN";
NSString* const kRed          = @"RED";

NSString* const kTrashYellow  = @"trashYellow";
NSString* const kTrashGreen   = @"trashGreen";
NSString* const kTrashRed     = @"trashRed";

NSString* const kTrashPickerYellow  = @"trashPickerYellow";
NSString* const kTrashPickerGreen   = @"trashPickerGreen";
NSString* const kTrashPickerRed     = @"trashPickerRed";

NSString* const kMoreButtonImageName = @"more_dashes" ;

@end
