//
//  SemaphoreViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/3/5.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "SemaphoreViewController.h"

@interface SemaphoreViewController ()
@property (nonatomic, strong) NSDateFormatter *formatter;
@end

@implementation SemaphoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat = @" YYYY-MM-dd HH:mm:ss";
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 50, 30)];
    [btn setTitle:@"start" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    dispatch_semaphore_t sema = dispatch_semaphore_create(3);
//    for (NSUInteger i=0; i<50; i++) {
//        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//        NSLog(@"%@",[_formatter stringFromDate:[NSDate date]]);
//        dispatch_semaphore_signal(sema);
//    }
}
- (void)startRequest {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Request_1");
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"Request_2");
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Request_3");
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"任务均完成，刷新界面");
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end