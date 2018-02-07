//
//  LineChartViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/1/29.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "LineChartViewController.h"
#import "LineChartView.h"
@interface LineChartViewController ()<CommonChartViewDelegate>

@end

@implementation LineChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSDictionary *dict = @{
                           @"axis":@[@"Mon",@"Tues",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun"],
                           @"datas":@[
                                   @[@"-9.6",@"0.2",@"990.3",@"-0.4",@"10.5",@"0.6",@"-0.7"],
                                   @[@"0.5",@"125.6",@"-0.7",@"91.9",@"10.12",@"0.13",@"-0.14"]
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
    LineChartView *chartView = [[LineChartView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) configure:dict];
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
