//
//  LockDemoViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/3/22.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "LockDemoViewController.h"
#import <pthread.h>

@interface LockDemoViewController ()
@property (nonatomic, strong) NSArray *datas;
@end

@implementation LockDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _datas = @[@"recursiveLock",@"pthreadRecursiveLock",@"semaphoreLock"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = self.datas[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SEL sel = NSSelectorFromString(self.datas[indexPath.row]);
    [self performSelector:sel];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)recursiveLock {
    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
//    NSLock *lock = [[NSLock alloc] init];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        static void (^RecursiveLock)(int);
        RecursiveLock = ^(int value){
            [lock lock];
            if (value > 0) {
                NSLog(@"%d",value);
                sleep(1);
                RecursiveLock(--value);
            }
            [lock unlock];
            NSLog(@"after Lock");

        };
            RecursiveLock(3);
    });
}

/**
 pthread
 */
// 摘录于YYKit
static inline void pthread_mutex_init_recursive(pthread_mutex_t *mutex, bool recursive) {
#define YYMUTEX_ASSERT_ON_ERROR(x_) do { \
__unused volatile int res = (x_); \
assert(res == 0); \
} while (0)
    assert(mutex != NULL);
    if (!recursive) {
        //普通锁
        YYMUTEX_ASSERT_ON_ERROR(pthread_mutex_init(mutex, NULL));
    } else {
        //递归锁
        pthread_mutexattr_t attr;
        YYMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_init (&attr));
        YYMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_settype (&attr, PTHREAD_MUTEX_RECURSIVE));
        YYMUTEX_ASSERT_ON_ERROR(pthread_mutex_init (mutex, &attr));
        YYMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_destroy (&attr));
    }
#undef YYMUTEX_ASSERT_ON_ERROR
}

- (void)pthreadRecursiveLock {
    __block pthread_mutex_t lock;
    pthread_mutex_init_recursive(&lock,true);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        static void (^RecursiveLock)(int);
        RecursiveLock = ^(int value){
            pthread_mutex_lock(&lock);
            if (value > 0) {
                NSLog(@"%d",value);
                sleep(1);
                RecursiveLock(--value);
            }
            pthread_mutex_unlock(&lock);
            NSLog(@"after Lock");
            
        };
        RecursiveLock(3);
    });
}

- (void)semaphoreLock {
    dispatch_semaphore_t sema = dispatch_semaphore_create(1);
    for (int i=3; i>0; i--) {
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        NSLog(@"%d",i);
        sleep(1);
        dispatch_semaphore_signal(sema);
    }
}
@end
