//
//  BWAnalyseViewController.m
//  BinWatch
//
//  Created by Supritha Nagesha on 10/10/15.
//  Copyright (c) 2015 Airwatch. All rights reserved.
//

#import "BWAnalyseViewController.h"
#import "BWDataHandler.h"
#import "BWConstants.h"
#import "BWBin.h"

#import "BWConnectionHandler.h"
#import "UUChart.h"

@interface BWAnalyseViewController ()<UUChartDataSource>
@property (weak, nonatomic) IBOutlet UILabel *queryLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateRangeLabel;
@property (weak, nonatomic) IBOutlet UITextView *binDetailsTextView;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) UUChart *uuChart;

@end

@implementation BWAnalyseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for(NSDictionary *obj in self.bins){
        BWBin *bin  = [obj objectForKey:@"Bin"];
        self.binDetailsTextView.text = [self.binDetailsTextView.text stringByAppendingString:[NSString stringWithFormat:@"%@ - %@%%\n",bin.area,bin.fill]];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    [_dateRangeLabel setText:[NSString stringWithFormat:@"%@ - %@",[formatter stringFromDate:_fromDate],[formatter stringFromDate:_toDate]]];
    [_queryLabel setText:_query];
    
    _uuChart = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 10, self.view.bounds.size.width-20, 200)
                                             withSource:self
                                              withStyle:UUChartLineStyle];
    [_uuChart showInView:self.bezirGraphView];
    
}

#pragma mark - @required
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    NSDictionary *biggestDict = [_bins objectAtIndex:0];
    
    if ([_bins count]>1) {
        
        for(NSDictionary *dict in _bins){
            if ([dict count]>[biggestDict count]) {
                biggestDict = dict;
            }
        }
    }
    
    NSArray *dataA = [biggestDict valueForKey:@"DataArray"];
    NSString * str = [[dataA valueForKeyPath:@"timestamp"] componentsJoinedByString:@","];
    NSArray *dateArray = [str componentsSeparatedByString:@","];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:dateArray];
    NSMutableArray *returnArray = [NSMutableArray array];
    if ([mutableArray count]%7 == 0) {
        
        int multiplier = [mutableArray count]==7?1:7;
        for(int i = 0;i <7; i++){
            [returnArray addObject:[mutableArray objectAtIndex:i*multiplier]];
        }
        
    }else{
        if ([mutableArray count]>7) {
            
            [mutableArray removeObjectsInRange:NSMakeRange([mutableArray count]-([mutableArray count]%7)-1 , [mutableArray count]%7)];
            int multiplier = [mutableArray count]== 7?1:7;
            for(int i = 0; i < 7; i++){
                [returnArray addObject:[mutableArray objectAtIndex:i*multiplier]];
            }
            
        }else{
            for(int i = 0;i <[mutableArray count]; i++){
                [returnArray addObject:[mutableArray objectAtIndex:i]];
            }
        }
    }
    
//    NSMutableArray *finalreturnArray = [NSMutableArray array];
//    for(NSDate *date in returnArray){
//        NSString *dateStr = [self.dateFormatter stringFromDate:date];
//        [finalreturnArray addObject:dateStr];
//    }
    
    return returnArray;
}

-(NSDateFormatter *)dateFormatter{
    
    if (!_dateFormatter) {
         _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"dd/MM/yyyy"];
    }
    return _dateFormatter;

}

- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    NSMutableArray *objectsArr = [NSMutableArray array];
    
    for(NSDictionary *obj in _bins){
        NSMutableArray *returnArray = [NSMutableArray array];
        NSArray *dataA = [obj valueForKey:@"DataArray"];
        NSString *key = [_query isEqualToString:@"Fill Trend"]?@"fill":@"temperature";
        NSString * str = [[dataA valueForKeyPath:key] componentsJoinedByString:@","];
        NSArray *fillArray = [str componentsSeparatedByString:@","];
        NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:fillArray];
        
        if ([mutableArray count]%7 == 0) {
            
            int multiplier = [mutableArray count]==7?1:7;
            for(int i = 0;i <7; i++){
                [returnArray addObject:[mutableArray objectAtIndex:i*multiplier]];
            }
            
        }else{
            if ([mutableArray count]>7) {
                
                [mutableArray removeObjectsInRange:NSMakeRange([mutableArray count]-([mutableArray count]%7)-1 , [mutableArray count]%7)];
                int multiplier = [mutableArray count]== 7?1:7;
                for(int i = 0; i < 7; i++){
                    [returnArray addObject:[mutableArray objectAtIndex:i*multiplier]];
                }
                
            }else{
                for(int i = 0;i <[mutableArray count]; i++){
                    [returnArray addObject:[mutableArray objectAtIndex:i]];
                }
            }
        }
        
        [objectsArr addObject:returnArray];
    }
    
    return objectsArr;
}

#pragma mark - @optional
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[UUGreen,UURed,UUBrown];
}

- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    
    return CGRangeMake(100, 0);
   
}

- (CGRange)UUChartMarkRangeInLineChart:(UUChart *)chart
{
   return  CGRangeMake(25, 75);
}

- (BOOL)UUChart:(UUChart *)chart ShowHorizonLineAtIndex:(NSInteger)index
{
    return YES;
}

- (BOOL)UUChart:(UUChart *)chart ShowMaxMinAtIndex:(NSInteger)index
{
    return YES;
}
@end
