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
    [[CustomNotificationCenter defaultCenter] addObserver:self selector:@selector(anotherTestNotification) name:@"noParamNotification" object:nil];
    
    [[CustomNotificationCenter defaultCenter] postNotificationName:@"noParamNotification" object:nil];
    [[CustomNotificationCenter defaultCenter] postNotificationName:@"noParamNotification" object:[NSObject new] userInfo:nil];
    [[CustomNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"noParamNotification" object:[NSObject new]]];
    
    [[CustomNotificationCenter defaultCenter] addObserver:self selector:@selector(testNotificationWithParam:) name:@"testNotificationWithParam" object:nil];
    [[CustomNotificationCenter defaultCenter] postNotificationName:@"testNotificationWithParam" object:nil];
    [[CustomNotificationCenter defaultCenter] postNotificationName:@"testNotificationWithParam" object:nil userInfo:@{@"param":@"i am param"}];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemNotificationWithObjectSel) name:@"systemNotificationWithObject" object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anotherSystemNotificationWithObjectSel) name:@"systemNotificationWithObject" object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemNotificationSel) name:@"systemNotification" object:nil];
    
    [[CustomNotificationCenter defaultCenter] addObserverForName:@"notificationUsingBlock" observer:self queue:nil usingBlock:^(CustomObserverInfo * _Nonnull info) {
        NSLog(@"usingBlock ==== %@ . default queue",info.name);
    }];
    
    NSOperationQueue *customQueue = [[NSOperationQueue alloc] init];
    customQueue.name = @"yh_custom_queue";
    [[CustomNotificationCenter defaultCenter] addObserverForName:@"notificationUsingBlock" observer:self queue:customQueue usingBlock:^(CustomObserverInfo * _Nonnull info) {
        NSLog(@"usingBlock ==== %@ . queue's name ==== %@",info.name,info.queue.name);
    }];
    
    [[CustomNotificationCenter defaultCenter] postNotificationName:@"notificationUsingBlock" object:nil];
}

- (void)testNotification {
    NSLog(@"trigger %s",__func__);
}

- (void)anotherTestNotification {
    NSLog(@"trigger %s",__func__);
}

- (void)testNotificationWithParam:(CustomObserverInfo *)info {
    NSLog(@"%@",info.userInfo);
}

- (void)systemNotificationSel {
    NSLog(@"systemNotificationSel ===");
}

- (void)systemNotificationWithObjectSel {
    NSLog(@"systemNotificationWithObjectSel ===");
}

- (void)anotherSystemNotificationWithObjectSel {
    NSLog(@"anotherSystemNotificationWithObjectSel ===");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"systemNotificationWithObject" object:self]; // addObserver:selector:name:object:anObject; name 和 object 都一致，才能监听到通知
}

- (void)dealloc {
    NSLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

@end
