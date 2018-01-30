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
    HorizontalBarChartView *chartView = [[HorizontalBarChartView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    [self.view addSubview:chartView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
