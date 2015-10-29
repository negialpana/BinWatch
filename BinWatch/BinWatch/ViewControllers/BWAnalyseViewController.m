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
#import "GraphView.h"
#import "UUChart.h"

@interface BWAnalyseViewController ()<UUChartDataSource>{
    NSArray *activeBins;
}

@property (weak, nonatomic) IBOutlet UILabel *queryLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateRangeLabel;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphView;
@property (weak, nonatomic) IBOutlet UITextView *binDetailsTextView;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) CPTBarPlot *aaplPlot;
@property (nonatomic, strong) CPTBarPlot *googPlot;
@property (nonatomic, strong) CPTBarPlot *msftPlot;
@property (nonatomic, strong) CPTPlotSpaceAnnotation *priceAnnotation;

@property (nonatomic, strong) UUChart *uuChart;

-(IBAction)aaplSwitched:(id)sender;
-(IBAction)googSwitched:(id)sender;
-(IBAction)msftSwitched:(id)sender;

-(void)initPlot;
-(void)configureGraph;
-(void)configurePlots;
-(void)configureAxes;

-(void)hideAnnotation:(CPTGraph *)graph;

@end

@implementation BWAnalyseViewController

CGFloat const CPDBarWidth = 0.25f;
CGFloat const CPDBarInitialX = 0.25f;

@synthesize aaplPlot    = aaplPlot_;
@synthesize googPlot    = googPlot_;
@synthesize msftPlot    = msftPlot_;
@synthesize priceAnnotation = priceAnnotation_;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for(NSDictionary *obj in self.bins){
        BWBin *bin  = [obj objectForKey:@"Bin"];
        self.binDetailsTextView.text = [self.binDetailsTextView.text stringByAppendingString:[NSString stringWithFormat:@"%@ - %@%%\n",bin.area,bin.fill]];
    }
    activeBins = [[BWDataHandler sharedHandler] fetchBins];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    [_dateRangeLabel setText:[NSString stringWithFormat:@"%@ - %@",[formatter stringFromDate:_fromDate],[formatter stringFromDate:_toDate]]];
    [_queryLabel setText:_query];
    
     [self initPlot];
    _uuChart = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 10, self.view.bounds.size.width-20, 200)
                                             withSource:self
                                              withStyle:UUChartLineStyle];
    [_uuChart showInView:self.bezirGraphView];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    GraphView *gv = [[GraphView alloc] initWithFrame:self.bezirGraphView.bounds];
//    gv.binsArray = self.bins;
//    gv.backgroundColor = [UIColor clearColor];
   // [self.bezirGraphView addSubview:gv];
}


#pragma mark - IBActions
-(IBAction)aaplSwitched:(id)sender {
}

-(IBAction)googSwitched:(id)sender {
}

-(IBAction)msftSwitched:(id)sender {
}

#pragma mark - Chart behavior
-(void)initPlot {
    self.graphView.allowPinchScaling = NO;
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureGraph {
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.graphView.bounds];
    graph.plotAreaFrame.masksToBorder = NO;
    self.graphView.hostedGraph = graph;
    // 2 - Configure the graph
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    graph.paddingBottom = 30.0f;
    graph.paddingLeft  = 30.0f;
    graph.paddingTop    = -1.0f;
    graph.paddingRight  = -5.0f;
    // 3 - Set up styles
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor colorWithCGColor:[AppTheme CGColor]];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    // 4 - Set up title
    NSString *title = @"<Location>";
    graph.title = title;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, -16.0f);
    // 5 - Set up plot space
    CGFloat xMin = 0.0f;
    CGFloat xMax = [activeBins count];
    CGFloat yMin = 0.0f;
    CGFloat yMax = 130.0f;  // should determine dynamically based on max price
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
}

-(void)configurePlots {
    // 1 - Set up the three plots
    self.aaplPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor redColor] horizontalBars:NO];
    self.aaplPlot.identifier = CPDTickerSymbolAAPL;
    self.googPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor] horizontalBars:NO];
    self.googPlot.identifier = CPDTickerSymbolGOOG;
    self.msftPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
    self.msftPlot.identifier = CPDTickerSymbolMSFT;
    // 2 - Set up line style
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineColor = [CPTColor lightGrayColor];
    barLineStyle.lineWidth = 0.5;
    // 3 - Add plots to graph
    CPTGraph *graph = self.graphView.hostedGraph;
    CGFloat barX = CPDBarInitialX;
    NSArray *plots = [NSArray arrayWithObjects:self.aaplPlot, self.googPlot, self.msftPlot, nil];
    for (CPTBarPlot *plot in plots) {
        plot.dataSource = self;
        plot.delegate = self;
        plot.barWidth = CPTDecimalFromDouble(CPDBarWidth);
        plot.barOffset = CPTDecimalFromDouble(barX);
        plot.lineStyle = barLineStyle;
        [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
        barX += CPDBarWidth;
    }
}

-(void)configureAxes {
    // 1 - Configure styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor colorWithCGColor:[AppTheme CGColor]];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [[CPTColor colorWithCGColor:[AppTheme CGColor]] colorWithAlphaComponent:1];
    // 2 - Get the graph's axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.graphView.hostedGraph.axisSet;
    // 3 - Configure the x-axis
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.xAxis.title = @"Bins";
    axisSet.xAxis.titleTextStyle = axisTitleStyle;
    axisSet.xAxis.titleOffset = 10.0f;
    axisSet.xAxis.axisLineStyle = axisLineStyle;
    // 4 - Configure the y-axis
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.yAxis.title = @"Fill / Humidity / Temp";
    axisSet.yAxis.titleTextStyle = axisTitleStyle;
    axisSet.yAxis.titleOffset = 5.0f;
    axisSet.yAxis.axisLineStyle = axisLineStyle;
}

-(void)hideAnnotation:(CPTGraph *)graph {
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CPTBarPlotDelegate methods
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index {
    // 1 - Is the plot hidden?
    if (plot.isHidden == YES) {
        return;
    }
    // 2 - Create style, if necessary
    static CPTMutableTextStyle *style = nil;
    if (!style) {
        style = [CPTMutableTextStyle textStyle];
        style.color= [CPTColor colorWithCGColor:[AppTheme CGColor]];
        style.fontSize = 16.0f;
        style.fontName = @"Helvetica-Bold";
    }
    // 3 - Create annotation, if necessary
    NSNumber *price = [self numberForPlot:plot field:CPTBarPlotFieldBarTip recordIndex:index];
    if (!self.priceAnnotation) {
        NSNumber *x = [NSNumber numberWithInt:0];
        NSNumber *y = [NSNumber numberWithInt:0];
        NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
        self.priceAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
    }
    // 4 - Create number formatter, if needed
    static NSNumberFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setMaximumFractionDigits:2];
    }
    // 5 - Create text layer for annotation
    NSString *priceValue = [formatter stringFromNumber:price];
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:priceValue style:style];
    self.priceAnnotation.contentLayer = textLayer;
    // 6 - Get plot index based on identifier
    NSInteger plotIndex = 0;
    if ([plot.identifier isEqual:CPDTickerSymbolAAPL] == YES) {
        plotIndex = 0;
    } else if ([plot.identifier isEqual:CPDTickerSymbolGOOG] == YES) {
        plotIndex = 1;
    } else if ([plot.identifier isEqual:CPDTickerSymbolMSFT] == YES) {
        plotIndex = 2;
    }
    // 7 - Get the anchor point for annotation
    CGFloat x = index + CPDBarInitialX + (plotIndex * CPDBarWidth);
    NSNumber *anchorX = [NSNumber numberWithFloat:x];
    CGFloat y = [price floatValue] + 40.0f;
    NSNumber *anchorY = [NSNumber numberWithFloat:y];
    self.priceAnnotation.anchorPlotPoint = [NSArray arrayWithObjects:anchorX, anchorY, nil];
    // 8 - Add the annotation
    [plot.graph.plotAreaFrame.plotArea addAnnotation:self.priceAnnotation];
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [activeBins count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if ((fieldEnum == CPTBarPlotFieldBarTip) && (index < [activeBins count])) {
        BWBin *bin = [activeBins objectAtIndex:index];
        if ([plot.identifier isEqual:CPDTickerSymbolAAPL]) {
            return bin.fill;
        } else if ([plot.identifier isEqual:CPDTickerSymbolGOOG]) {
            return bin.humidity;
        } else if ([plot.identifier isEqual:CPDTickerSymbolMSFT]) {
            return bin.temperature;
        }
    }
    return [NSDecimalNumber numberWithUnsignedInteger:index];
}

///////
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
        NSString * str = [[dataA valueForKeyPath:@"fill"] componentsJoinedByString:@","];
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
