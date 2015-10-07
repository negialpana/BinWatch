//
//  GradientView.m
//  BinWatch
//
//  Created by Ponnie Rohith on 10/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "GradientView.h"
#import "BWHelpers.h"

@implementation GradientView

CAGradientLayer *gradientLayer;


- (instancetype)initWithFrame:(CGRect)frame forfill:(float)fill;
{
    self = [super initWithFrame:frame];
    if (self) {
        UIColor *first,*last;
        BWBinColor color = [BWHelpers colorForPercent:fill];
        switch (color) {
            case BWGreen:
                first = DarkGreen;
                last = LightGreen;
                break;
            case BWYellow:
                first = DarkYellow;
                last = LightYellow;
                break;
            case BWRed:
                first = DarkRed;
                last = LightRed;
                break;
                
            default:
                first = DarkGreen;
                last = LightGreen;
                break;
        }
        CGFloat fraction = fill / 100.0 ;
        CGRect gradientFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, fraction * self.bounds.size.width, self.bounds.size.height);

        gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = gradientFrame;
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[first CGColor],(id)[last CGColor], nil];
        gradientLayer.startPoint = CGPointMake(0.0, 0.0);
        gradientLayer.endPoint = CGPointMake(1.0, 0.0);
        [self.layer insertSublayer:gradientLayer atIndex:0];
    }
    return self;
}
@end
