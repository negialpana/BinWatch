//
//  GradientView.m
//  BinWatch
//
//  Created by Ponnie Rohith on 10/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

CAGradientLayer *gradientLayer;

- (instancetype)initWithFrame:(CGRect)frame forColor:(BWBinColor)color
{
    self = [super initWithFrame:frame];
    if (self) {
        UIColor *first,*last;
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
        gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = self.bounds;
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[first CGColor],(id)[last CGColor], nil];
        gradientLayer.startPoint = CGPointMake(0.0, 0.0);
        gradientLayer.endPoint = CGPointMake(1.0, 0.0);
        //        gradientLayer.locations = @[@0.0,@1.0];
        
        [self.layer insertSublayer:gradientLayer atIndex:0];
    }
    return self;
}
@end
