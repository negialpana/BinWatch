//
//  BWDocumentHelper.h
//  BinWatch
//
//  Created by Seema Kadavan on 10/12/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BWDocumentHelper : NSObject
- (void) exportToCSV;
- (void)createPDFfromUIView:(UIView*)aView saveToDocumentsWithFileName:(NSString*)aFilename;
+ (void)sendByMail:(NSString *)name forView:(UIViewController*)parent;
@end
