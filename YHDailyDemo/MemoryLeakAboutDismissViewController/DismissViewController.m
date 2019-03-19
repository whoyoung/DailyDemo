//
//  DismissViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/12/1.
//  Copyright © 2018 杨虎. All rights reserved.
//

#import "DismissViewController.h"

@interface DismissViewController ()

@property (nonatomic, assign) NSUInteger number;
@property (nonatomic, strong) NSDictionary *dict;

@end

@implementation DismissViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    self.number = 10;
    self.dict = @{@"name" : @"dict"};
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)dealloc {
    NSLog(@"DismissViewController  dealloc =====");
}

@end
