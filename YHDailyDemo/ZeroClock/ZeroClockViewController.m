//
//  ZeroClockViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/6/4.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "ZeroClockViewController.h"

@interface ZeroClockViewController ()

@end

@implementation ZeroClockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 获取当前时区零点时间戳
    NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *comps = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSDateComponents *zeroComps = [[NSDateComponents alloc] init];
    zeroComps.year = comps.year;
    zeroComps.month = comps.month;
    zeroComps.day = comps.day;
    zeroComps.hour = 0;
    zeroComps.minute = 0;
    zeroComps.second = 0;
    NSDate *date = [cal dateFromComponents:zeroComps];
    NSUInteger zeroSec = date.timeIntervalSince1970;
    NSLog(@"current zone zeroSec = %lu",(unsigned long)zeroSec);
}

@end
