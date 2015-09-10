//
//  GradientView.m
//  BinWatch
//
//  Created by Ponnie Rohith on 10/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

CAGradientLayer *gradientl;

- (instancetype)initWithColor:(BWBinColor)color
{
    self = [super init];
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
        gradientl = [CAGradientLayer layer];
        gradientl.frame = self.bounds;
        gradientl.colors = [NSArray arrayWithObjects:(id)[first CGColor],(id)[last CGColor], nil];
        gradientl.startPoint = CGPointMake(0.0, 0.0);
        gradientl.endPoint = CGPointMake(1.0, 0.0);
        //        gradient.locations = @[@0.0,@1.0];
        

    }
    return self;
}
@end
