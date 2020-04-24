
//
//  MLeaksFinderDemoViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/6/10.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "MLeaksFinderDemoViewController.h"
#import "LeakView.h"
#import "TestDemoProtoc.h"
@interface MLeaksFinderDemoViewController ()
@property (nonatomic, strong) LeakView *leakV;
@property (nonatomic, strong) UIColor *color;

@property (nonatomic, strong) NSMapTable *dict;

@end

@implementation MLeaksFinderDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _leakV = [[LeakView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 100)];
    _leakV.block = ^{
//        self.view.backgroundColor = [UIColor blueColor];
    };
    [self.view addSubview:_leakV];
    self.dict = [NSMapTable strongToWeakObjectsMapTable];
    [self.dict setObject:@"1" forKey:@protocol(TestDemoProtoc)];
}


- (void)dealloc {
    NSLog(@"i am dead!");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
