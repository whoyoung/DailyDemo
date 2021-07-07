//
//  NotiBlockViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2021/7/7.
//  Copyright © 2021 杨虎. All rights reserved.
//

#import "NotiBlockViewController.h"
#import "NotiBlockSecondaryViewController.h"
#import "YHDailyDemo-Swift.h"

@interface NotiBlockViewController ()

@end

@implementation NotiBlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [btn addTarget:self action:@selector(nextPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(0, 0, 100, 40);
    btn.center = self.view.center;
    
    UIButton *swiftBtn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [swiftBtn addTarget:self action:@selector(nextSwiftPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:swiftBtn];
    swiftBtn.frame = CGRectMake(CGRectGetMinX(btn.frame), CGRectGetMaxY(btn.frame) + 50, 100, 40);
}

- (void)nextPage {
    NotiBlockSecondaryViewController *secondary = [[NotiBlockSecondaryViewController alloc] init];
    [self.navigationController pushViewController:secondary animated:YES];
}

- (void)nextSwiftPage {
    NotiBlockSecondarySwiftViewController *secondary = [[NotiBlockSecondarySwiftViewController alloc] init];
    [self.navigationController pushViewController:secondary animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SendNotiBlockNotification" object:nil];
}

@end
