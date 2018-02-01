//
//  HorizontalBarChartViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/1/30.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "HorizontalBarChartViewController.h"
#import "HorizontalBarChartView.h"
@interface HorizontalBarChartViewController ()

@end

@implementation HorizontalBarChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSDictionary *dict = @{
                           @"axis":@[@"Mon",@"Tues",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun"],
                           @"datas":@[
                                     @[@"9.6",@"0.2",@"0.3",@"-0.4",@"0.5",@"0.6",@"-0.7"],
                                     @[@"0.5",@"0.6",@"-0.7",@"0.9",@"0.12",@"0.13",@"-0.14"]
                                    ],
                           @"groupMembers":@[@"zhang",@"yang"],
                           @"axisTitle":@"星期",
                           @"dataTitle":@"成交量",
                           @"displayType":@"2", //0:single, 1:group, 2:stack
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
    HorizontalBarChartView *chartView = [[HorizontalBarChartView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) configure:dict];
    [self.view addSubview:chartView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
