//
//  YHTempViewController.m
//  YHDailyDemo
//
//  Created by young on 2019/8/28.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "YHTempViewController.h"

@interface YHTempViewController ()

@property (nonatomic, weak) id obj;

@end

@implementation YHTempViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 系统 dealloc 时，自动移除观察者
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiSelector) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];

    // 系统 dealloc 时，不会自动移除观察者
//    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
//        NSLog(@"notiBlock =====");
//    }];
    
    // 有内存泄露，不会调用 dealloc 方法，不会自动移除观察者
//    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil     queue:nil usingBlock:^(NSNotification * _Nonnull note) {
//        NSLog(@"notiBlock capture self %p =====",self);
//    }];
    
    // 系统 dealloc 时，不会自动移除观察者
//    __weak typeof(self) weakSelf = self;
//        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil     queue:nil usingBlock:^(NSNotification * _Nonnull note) {
//            NSLog(@"notiBlock capture weakSelf %p =====",weakSelf);
//        }];

    // 系统 dealloc 时，不会自动移除观察者。 需要当前类持有观察者，在 dealloc 中移除观察者，才能停止监听通知
    // The return value is retained by the system, and should be held onto by the caller in
    // order to remove the observer with removeObserver: later, to stop observation.
    self.obj = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"notiBlock =====");
    }];
}

- (void)notiSelector {
    NSLog(@"notiSelector =====");
}

- (void)dealloc {
    NSLog(@"%s =====",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self.obj];
}

@end
