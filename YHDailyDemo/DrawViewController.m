//
//  DrawViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/1/19.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "DrawViewController.h"
#import "DrawView.h"
@interface DrawViewController ()

@end

@implementation DrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    DrawView *drawView = [[DrawView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.height-100)];
    [self.view addSubview:drawView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
