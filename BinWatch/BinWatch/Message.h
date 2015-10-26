//
//  Message.h
//  Kaizen
//
//  Created by Ponnie Rohith on 28/03/15.
//  Copyright (c) 2015 PR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Message : NSObject
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *time;

- (instancetype)initWithText:(NSString*)messageText;

@end
