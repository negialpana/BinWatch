//
//  GradientTableViewCell.m
//  BinWatch
//
//  Created by Ponnie Rohith on 10/09/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "GradientTableViewCell.h"

@implementation GradientTableViewCell

CAGradientLayer *gradient;
-(instancetype)initWithColor:(BWBinColor)color reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]) {
        
        self.textLabel.textColor = [UIColor blackColor];
        self.detailTextLabel.textColor = [UIColor blackColor];

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
        gradient = [CAGradientLayer layer];
        gradient.frame = self.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[first CGColor],(id)[last CGColor], nil];
        gradient.startPoint = CGPointMake(0.0, 0.0);
        gradient.endPoint = CGPointMake(1.0, 0.0);
//        gradient.locations = @[@0.0,@1.0];

        UIView *background = [UIView new];
        [self.layer insertSublayer:gradient atIndex:0];
        background.backgroundColor = [UIColor greenColor];

//        self.backgroundView = background;
    }
    return self;

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    for (UIView *view in self.contentView.subviews) {
        view.backgroundColor = [UIColor clearColor];

    }
}
@end
