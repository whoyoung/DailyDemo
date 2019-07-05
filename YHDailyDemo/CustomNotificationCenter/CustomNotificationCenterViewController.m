//
//  CustomNotificationCenterViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/7/3.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "CustomNotificationCenterViewController.h"
#import "CustomNotificationCenter.h"
#import "CustomObserverInfo.h"

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
    
    [[CustomNotificationCenter defaultCenter] addObserver:self selector:@selector(testNotificationWithParam:) name:@"testNotificationWithParam" object:nil];
    [[CustomNotificationCenter defaultCenter] postNotificationName:@"testNotificationWithParam" object:nil];
    [[CustomNotificationCenter defaultCenter] postNotificationName:@"testNotificationWithParam" object:nil userInfo:@{@"param":@"i am param"}];
}

- (void)testNotification {
    NSLog(@"trigger %s",__func__);
}

- (void)testNotificationWithParam:(CustomObserverInfo *)info {
    NSLog(@"%@",info.userInfo);
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

@end
