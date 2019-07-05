//
//  CustomNotificationCenterViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/7/3.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "CustomNotificationCenterViewController.h"
#import "CustomNotificationCenter.h"

@interface CustomNotificationCenterViewController ()

@end

@implementation CustomNotificationCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[CustomNotificationCenter defaultCenter] addObserver:self selector:@selector(testNotification) name:@"noParamNotification" object:nil];
    [[CustomNotificationCenter defaultCenter] addObserver:self selector:@selector(testNotification) name:@"noParamNotification" object:nil]; // 不会重复添加通知
    [[CustomNotificationCenter defaultCenter] postNotificationName:@"noParamNotification" object:nil];
    [[CustomNotificationCenter defaultCenter] postNotificationName:@"noParamNotification" object:[NSObject new] userInfo:nil];
    [[CustomNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"noParamNotification" object:[NSObject new]]];
}

- (void)testNotification {
    NSLog(@"trigger %s",__func__);
}

@end
