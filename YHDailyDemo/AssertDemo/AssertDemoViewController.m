//
//  AssertDemoViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2021/4/29.
//  Copyright © 2021 杨虎. All rights reserved.
//

#import "AssertDemoViewController.h"

@interface AssertDemoViewController ()

@end

@implementation AssertDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    assert(NO); // debug / release 配置下都会 crash
}

@end
