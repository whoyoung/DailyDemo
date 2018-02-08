//
//  VerticalBarChartViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/1/31.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "VerticalBarChartViewController.h"
#import "YHVerticalBarChartView.h"
@interface VerticalBarChartViewController ()<YHCommonChartViewDelegate>

@end

@implementation VerticalBarChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSDictionary *dict = @{
                           @"axis":@[@"Mon",@"Tues",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun"],
                           @"datas":@[
                                   @[@"9883.6",@"580.2",@"980.3",@"-3330.4",@"10.5",@"0.6",@"-70.7"],
                                   @[@"10.5",@"12533.6",@"-58.7",@"91.9",@"1066.12",@"50.13",@"-6033.14"]
                                   ],
                           @"groupMembers":@[@"zhang",@"yang"],
                           @"axisTitle":@"星期",
                           @"dataTitle":@"成交量",
                           @"stack":@YES,
                           @"valueInterval": @"3",
                           @"styles": @{
                                   @"barStyle": @{
                                           @"minBarWidth":@"5",
                                           @"barGroupSpace":@"5"
                                           },
                                   @"lineStyle": @{
                                           @"lineWidth":@"1"
                                           }
                                   }
                           };
    YHVerticalBarChartView *chartView = [[YHVerticalBarChartView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) configure:dict];
    chartView.delegate = self;
    [self.view addSubview:chartView];
}
- (void)didTapChart:(id)chart group:(NSUInteger)group item:(NSUInteger)item {
    NSLog(@"group=%ld, item=%ld",group,item);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
