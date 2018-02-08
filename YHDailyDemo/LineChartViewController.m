//
//  LineChartViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/1/29.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "LineChartViewController.h"
#import "YHLineChartView.h"
@interface LineChartViewController ()<YHCommonChartViewDelegate>

@end

@implementation LineChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSDictionary *dict = @{
                           @"axis":@[@"Mon",@"Tues",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun"],
                           @"datas":@[
                                   @[@"-9555.6",@"40.2",@"11190.3",@"-330.4",@"10.5",@"380.6",@"-2220.7"],
                                   @[@"10.5",@"125.6",@"-670.7",@"91.9",@"510.12",@"220.13",@"-770.14"]
                                   ],
                           @"groupMembers":@[@"zhang",@"yang"],
                           @"axisTitle":@"星期",
                           @"dataTitle":@"成交量",
                           @"valueInterval": @"3",
                           @"styles": @{
                                   @"lineStyle": @{
                                           @"lineWidth":@"1"
                                           }
                                   }
                           };
    YHLineChartView *chartView = [[YHLineChartView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) configure:dict];
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
