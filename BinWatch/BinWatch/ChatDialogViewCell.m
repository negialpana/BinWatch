//
//  ChatDialogViewCell.m
//  Kaizen
//
//  Created by Ponnie Rohith on 28/03/15.
//  Copyright (c) 2015 PR. All rights reserved.
//

#import "ChatDialogViewCell.h"
#define padding 25


@implementation ChatDialogViewCell


static NSDateFormatter *messageDateFormatter;
static UIImage *aquaBubble;
CGFloat screenHeight;
CGFloat screenWidth;

+ (void)initialize{
    [super initialize];
    
    // init message datetime formatter
    messageDateFormatter = [[NSDateFormatter alloc] init];
//    [messageDateFormatter setDateFormat: @"yyyy-mm-dd HH:mm"];
    [messageDateFormatter setDateFormat: @"HH:mm"];
    [messageDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    // init bubbles
    aquaBubble = [[UIImage imageNamed:@"aquaBubble"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
    screenHeight = [UIScreen mainScreen].applicationFrame.size.height;
    screenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    if(UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
    {
        CGFloat width = screenHeight;
        screenHeight = screenWidth;
        screenWidth = width;
    }
}

+ (CGFloat)heightForCellWithMessage:(NSString *)message
{
    NSString *text = message;
    
    
    CGSize  textSize = {260.0, 10000.0};
    CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:13]
                   constrainedToSize:textSize
                       lineBreakMode:NSLineBreakByWordWrapping];
    
    
    size.height += 45.0;
    return size.height;
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.dateLabel = [[UILabel alloc] init];
        [self.dateLabel setFrame:CGRectMake(10, 5, 300, 20)];
        [self.dateLabel setFont:[UIFont systemFontOfSize:11.0]];
        [self.dateLabel setTextColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:self.dateLabel];
        
        self.backgroundImageView = [[UIImageView alloc] init];
        [self.backgroundImageView setFrame:CGRectZero];
        [self.contentView addSubview:self.backgroundImageView];
        
        self.messageTextView = [[UITextView alloc] init];
        [self.messageTextView setBackgroundColor:[UIColor clearColor]];
        [self.messageTextView setEditable:NO];
        [self.messageTextView setScrollEnabled:NO];
        [self.messageTextView sizeToFit];
        [self.contentView addSubview:self.messageTextView];
    }
    return self;
}

- (void)configureCellWithMessage:(Message *)message
{
    self.messageTextView.text = message.text;
    
    
    CGSize textSize = { 260.0, 10000.0 };
    
    CGSize size = [self.messageTextView.text sizeWithFont:[UIFont boldSystemFontOfSize:13]
                                        constrainedToSize:textSize
                                            lineBreakMode:NSLineBreakByWordWrapping];
    
    //    NSLog(@"message: %@", message);
    
    size.width += 10;
    
    NSString *time = [messageDateFormatter stringFromDate:message.time];
    
    // Left/Right bubble
        [self.messageTextView setFrame:CGRectMake(screenWidth-size.width-padding/2, padding+5, size.width, size.height+padding)];
        [self.messageTextView sizeToFit];
        
        [self.backgroundImageView setFrame:CGRectMake(screenWidth-size.width-padding, padding+5,
                                                      self.messageTextView.frame.size.width+padding, self.messageTextView.frame.size.height+5)];
        self.backgroundImageView.image = aquaBubble;
        
        self.dateLabel.textAlignment = NSTextAlignmentRight;
        self.dateLabel.text = time;
}

@end

