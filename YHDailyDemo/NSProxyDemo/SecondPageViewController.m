//
//  SecondPageViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/3/18.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "SecondPageViewController.h"
#import "YHWeakProxy.h"
@interface SecondPageViewController ()
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation SecondPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fireInTheHole) userInfo:nil repeats:YES];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:[YHWeakProxy proxyWithTarget:self] selector:@selector(fireInTheHole) userInfo:nil repeats:YES];
}
- (void)fireInTheHole {
    NSLog(@"Dong! Boom! Shakalaka!");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"i am dead!!!!!!!");
    if (self.timer) {
        [self.timer invalidate];
    }
}
@end
