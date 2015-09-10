//
//  ConnectionHandler.h
//  BinWatch
//
//  Created by Supritha Nagesha on 05/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionHandler : NSObject

+ (instancetype)sharedInstance;

- (void)getBinsWithCompletionHandler:(void(^)(NSArray *, NSError *))completionBlock;

@end
