//
//  BWBinLocatorViewController.h
//  BinWatch
//
//  Created by Supritha Nagesha on 03/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "BWRoute.h"
#import "BWSettingsControl.h"

@class SPGooglePlacesAutocompleteQuery;

@interface BWBinLocatorViewController : UIViewController <GMSMapViewDelegate, BWRouteDelegate, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, BWSettingsControlDelegate> {
}


@end
