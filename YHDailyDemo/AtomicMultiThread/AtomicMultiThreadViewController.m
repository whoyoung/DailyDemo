//
//  AtomicMultiThreadViewController.m
//  YHDailyDemo
//
//  Created by young on 2022/6/26.
//  Copyright © 2022 杨虎. All rights reserved.
//

#import "AtomicMultiThreadViewController.h"

@interface AtomicMultiThreadViewController ()

@property (atomic, assign) NSUInteger num;

@end

@implementation AtomicMultiThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (NSUInteger i = 0; i<1000; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            self.num += 1;
        });
    }
    
}

// [iOS 属性修饰符atomic并不是绝对安全的](https://blog.csdn.net/u014798232/article/details/82655695?utm_medium=distribute.pc_aggpage_search_result.none-task-blog-2~aggregatepage~first_rank_ecpm_v1~rank_v31_ecpm-3-82655695-null-null.pc_agg_new_rank&utm_term=atomic%E7%BB%9D%E5%AF%B9%E5%AE%89%E5%85%A8%E5%90%97&spm=1000.2123.3001.4430)
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    // num = 997
    NSLog(@"num = %ld", self.num);
}

@end
