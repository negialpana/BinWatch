//
//  BWViewRenderingHelper.h
//  BinWatch
//
//  Created by Alpana Negi on 10/7/15.
//  Copyright © 2015 Airwatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BWViewRenderingHelper : NSObject

+ (void)addBarGraphOnView:(UIView*)view atOrigin:(CGPoint)origin withFillLevel:(int)fillLevel;

@end
