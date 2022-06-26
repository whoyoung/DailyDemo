//
//  GCDMultiTheadExecutionViewController.m
//  YHDailyDemo
//
//  Created by young on 2022/6/26.
//  Copyright © 2022 杨虎. All rights reserved.
//

#import "GCDMultiTheadExecutionViewController.h"

@interface GCDMultiTheadExecutionViewController ()

@end

@implementation GCDMultiTheadExecutionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //    [self seriaQueueTest];
        
    [self concurrentQueueTest];
}

- (void)seriaQueueTest {
    NSLog(@"1");
    dispatch_queue_t seriaQ = dispatch_queue_create("yhSeria", DISPATCH_QUEUE_SERIAL);
    dispatch_async(seriaQ, ^{
        NSLog(@"2，%@",[NSThread currentThread]);
        dispatch_async(seriaQ, ^{
            NSLog(@"3，%@",[NSThread currentThread]);
        });
        dispatch_async(seriaQ, ^{
            NSLog(@"5，%@",[NSThread currentThread]);
        });
//        dispatch_sync(seriaQ, ^{ // 会阻塞线程崩溃
//            NSLog(@"4");
//            sleep(2);
//        });
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{ // 阻塞当前线程，在global_queue执行完此 block 之后，才执行异步任务
            sleep(5);
            NSLog(@"4，%@",[NSThread currentThread]);
        });
//        dispatch_async(dispatch_get_main_queue(), ^{ // block 加入主队列执行
//            sleep(5);
//            NSLog(@"4");
//        });
//        dispatch_sync(dispatch_get_main_queue(), ^{ // 阻塞当前线程，在主队列执行完此 block 之后，才执行异步任务
//            sleep(5);
//            NSLog(@"4，%@",[NSThread currentThread]);
//        });
        
        dispatch_async(seriaQ, ^{
            NSLog(@"6，%@",[NSThread currentThread]);
        });
        dispatch_async(seriaQ, ^{
            NSLog(@"7，%@",[NSThread currentThread]);
        });
        NSLog(@"seriaQ end，%@",[NSThread currentThread]);
    });
    NSLog(@"end");
}

- (void)concurrentQueueTest {
    NSLog(@"1");
    dispatch_queue_t curQ = dispatch_queue_create("yhConcurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(curQ, ^{
        NSLog(@"2，%@",[NSThread currentThread]);
        dispatch_async(curQ, ^{
            NSLog(@"3，%@",[NSThread currentThread]);
        });
        dispatch_async(curQ, ^{
            NSLog(@"5，%@",[NSThread currentThread]);
        });
//        dispatch_sync(curQ, ^{ // 会阻塞线程，当前 block 执行完后，才继续往下执行
//            sleep(5);
//            NSLog(@"4，%@",[NSThread currentThread]);
//        });
//        dispatch_sync(dispatch_get_global_queue(0, 0), ^{ // 阻塞当前线程，在global_queue执行完此 block 之后，才继续往下执行任务
//            sleep(5);
//            NSLog(@"4，%@",[NSThread currentThread]);
//        });
//        dispatch_async(dispatch_get_main_queue(), ^{ // block 加入主队列执行
//            sleep(5);
//            NSLog(@"4，%@",[NSThread currentThread]);
//        });
        dispatch_sync(dispatch_get_main_queue(), ^{ // 阻塞当前线程，在主队列执行完此 block 之后，才继续往下执行任务
            sleep(5);
            NSLog(@"4，%@",[NSThread currentThread]);
        });
        
        dispatch_async(curQ, ^{
            NSLog(@"6，%@",[NSThread currentThread]);
        });
        dispatch_async(curQ, ^{
            NSLog(@"7，%@",[NSThread currentThread]);
        });
        NSLog(@"curQ end，%@",[NSThread currentThread]);
    });
    NSLog(@"end");
}
@end
