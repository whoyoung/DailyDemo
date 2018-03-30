//
//  SemaphoreViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/3/5.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "SemaphoreViewController.h"
#import <objc/runtime.h>
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
        NSBlockOperation *blockO = [NSBlockOperation blockOperationWithBlock:^{
            dispatch_apply(3, dispatch_get_main_queue(), ^(size_t index) {
                NSLog(@"block %zu",index);
            });

        }];
        [blockO start];
        
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSBlockOperation *blockO = [NSBlockOperation blockOperationWithBlock:^{
            sleep(2);
            NSLog(@"Request_2");
        }];
        [blockO start];
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSBlockOperation *blockO = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"Request_3");
        }];
        [blockO start];
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"任务均完成，刷新界面");
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self startNSOperationQueueRequest];
    [super touchesBegan:touches withEvent:event];
}
- (void)startNSOperationQueueRequest {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1");
    }];
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"2");
    }];
    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"3");
    }];
    NSBlockOperation *operation4 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"4");
    }];
    
    queue.maxConcurrentOperationCount = 2;
    [queue addOperations:@[operation1,operation2,operation3,operation4] waitUntilFinished:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
