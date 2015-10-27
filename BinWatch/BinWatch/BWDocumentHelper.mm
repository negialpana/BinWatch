//
//  BWDocumentHelper.m
//  BinWatch
//
//  Created by Seema Kadavan on 10/12/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWDocumentHelper.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "BWBin.h"
#import "BWDataHandler.h"
#import "BWLogger.h"
#include "xlslib.h"

#define FILE_NAME_CSV @"BinWatch.csv"
#define FILE_NAME_PDF @"BinWatch.pdf"
#define FILE_NAME_XLS @"BinWatch.xls"

using namespace xlslib_core;

@implementation BWDocumentHelper

-(void) exportToXLS
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename=[NSString stringWithFormat:FILE_NAME_XLS];
    NSString *filePathLib = [NSString stringWithFormat:@"%@",[docDir stringByAppendingPathComponent:filename]];
    
    xlslib_core::workbook wb;
    worksheet* sh1 = wb.sheet("error");
    
    // Title
    sh1->label(0,0,"ADDRESS");
    sh1->label(0,1,"BIN ID");
    sh1->label(0,2,"LATITUDE");
    sh1->label(0,3,"LONGITUDE");
    sh1->label(0,4,"FILL PERCENTAGE");
    sh1->label(0,5,"TEMPERATURE");
    sh1->label(0,6,"HUMIDITY");
    sh1->label(0,7,"ACTIVE");
    sh1->label(0,8,"DATE");
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd-HH-mm-ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSArray *bins = [[BWDataHandler sharedHandler]fetchBins];
    int col;
    for(int i = 0; i < bins.count; i++)
    {
        col = 0;
        BWBin *bin = [bins objectAtIndex:i];
        sh1->label(i + 1, col++, [bin.place UTF8String]);
        sh1->label(i + 1, col++, [bin.binID UTF8String]);
        sh1->label(i + 1, col++, [[NSString stringWithFormat:@"%f",[bin.latitude floatValue]] UTF8String]);
        sh1->label(i + 1, col++, [[NSString stringWithFormat:@"%f",[bin.longitude floatValue]] UTF8String]);
        sh1->label(i + 1, col++, [[NSString stringWithFormat:@"%f",[bin.fill floatValue]] UTF8String]);
        sh1->label(i + 1, col++, [[NSString stringWithFormat:@"%f",[bin.temperature floatValue]] UTF8String]);
        sh1->label(i + 1, col++, [[NSString stringWithFormat:@"%f",[bin.humidity floatValue]] UTF8String]);
        sh1->label(i + 1, col++, [bin.isAcive?@"YES":@"NO" UTF8String]);
        sh1->label(i + 1, col++, [[dateFormatter stringFromDate:bin.date] UTF8String]);
    }
    int err = wb.Dump([filePathLib UTF8String]);
    if(err)
    {
        [BWLogger DoLog:@"Export to Excel failed"];
    }
}

-(void) exportToCSV
{
    NSString *filePath = [self createCSV];
    NSFileHandle *myHandle = [self getFileHandle:filePath];
    [self writeHeader:myHandle];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd-HH-mm-ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];

    NSArray *bins = [[BWDataHandler sharedHandler] fetchBins];
    for (BWBin *bin in bins)
    {
        NSString *binAddress = [bin.place stringByReplacingOccurrencesOfString:@"," withString:@" "];
        NSString *objects = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@", binAddress,bin.binID, bin.latitude, bin.longitude,bin.fill, bin.temperature, bin.humidity, bin.isAcive? @"YES":@"NO",[dateFormatter stringFromDate:bin.date]];
        [self writeNewline:myHandle];
        [self writeData:[objects dataUsingEncoding:NSUTF8StringEncoding] toFile:myHandle];
    }
}

// http://stackoverflow.com/questions/5443166/how-to-convert-uiview-to-pdf-within-ios
- (void)createPDFfromUIView:(UIView*)aView
{
    // Creates a mutable data object for updating with binary data, like a byte array
    NSMutableData *pdfData = [NSMutableData data];
    
    // Points the pdf converter to the mutable data object and to the UIView to be converted
    UIGraphicsBeginPDFContextToData(pdfData, aView.bounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    
    
    // draws rect to the view and thus this is captured by UIGraphicsBeginPDFContextToData
    
    [aView.layer renderInContext:pdfContext];
    
    // remove PDF rendering context
    UIGraphicsEndPDFContext();
    
    // Retrieves the document directories from the iOS device
    NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    
    NSString* documentDirectory = [documentDirectories objectAtIndex:0];
    NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:FILE_NAME_PDF];
    
    // instructs the mutable data object to write its context to a file on disk
    [pdfData writeToFile:documentDirectoryFilename atomically:YES];
}

-(void) deleteAllFiles
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePathCSV = [NSString stringWithFormat:@"%@",[docDir stringByAppendingPathComponent:FILE_NAME_CSV]];
    NSString *filePathPDF = [NSString stringWithFormat:@"%@",[docDir stringByAppendingPathComponent:FILE_NAME_PDF]];
    NSString *filePathXLS = [NSString stringWithFormat:@"%@",[docDir stringByAppendingPathComponent:FILE_NAME_XLS]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    if([fileManager fileExistsAtPath:filePathCSV])
        [fileManager removeItemAtPath:filePathCSV error:&error];

    if([fileManager fileExistsAtPath:filePathPDF])
        [fileManager removeItemAtPath:filePathPDF error:&error];

    if([fileManager fileExistsAtPath:filePathXLS])
        [fileManager removeItemAtPath:filePathXLS error:&error];
}

#pragma mark - Utility Methods
-(NSString *)createCSV
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename=[NSString stringWithFormat:FILE_NAME_CSV];
    NSString *filePathLib = [NSString stringWithFormat:@"%@",[docDir stringByAppendingPathComponent:filename]];
    
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:filePathLib error:&error];
    
    if (![[NSFileManager defaultManager] createFileAtPath:filePathLib contents:nil attributes:nil]){
        [BWLogger DoLog:@"Failed to create CSV"];
        return nil;
    }
    return filePathLib;
}

-(NSFileHandle *) getFileHandle:(NSString *)filePath
{
    return [NSFileHandle fileHandleForWritingAtPath:filePath];
}

-(void)writeNewline:(NSFileHandle *)fileHandle
{
    NSString *newline = @"\n";
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[newline dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)writeData:(NSData *)data toFile:(NSFileHandle *)fileHandle
{
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
}

-(void)writeHeader:(NSFileHandle *)fileHandle
{
    NSArray *array = [NSArray arrayWithObjects:@"ADDRESS,BIN ID,LATITUDE,LONGITUDE,FILL PERCENTAGE,TEMPERATURE,HUMIDITY,ACTIVE,DATE",nil];
    [self writeData:[[array componentsJoinedByString:@","] dataUsingEncoding:NSUTF8StringEncoding] toFile:fileHandle];
}

@end
