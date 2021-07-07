//
//  NotiBlockSecondaryViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2021/7/7.
//  Copyright © 2021 杨虎. All rights reserved.
//

#import "NotiBlockSecondaryViewController.h"

@interface NotiBlockSecondaryViewController ()

@property (nonatomic) NSObject *notiObserver;

@end

@implementation NotiBlockSecondaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.notiObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"SendNotiBlockNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.notiObserver];
    NSLog(@"%s is dealloc",__func__);
}

@end
