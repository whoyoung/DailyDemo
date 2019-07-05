//
//  NSPointerArrayAndNSMutabelSetViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/7/5.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "NSPointerArrayAndNSMutabelSetViewController.h"

@interface NSPointerArrayAndNSMutabelSetViewController ()

@end

@implementation NSPointerArrayAndNSMutabelSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSPointerArray *array = [NSPointerArray weakObjectsPointerArray];
    for (NSUInteger i = 0; i < 5; i++) {
        [array addPointer:(void *)[NSObject new]];
    }
    NSLog(@"array.count = %ld",array.count);
    [array addPointer:NULL]; // 不加上这句的话，直接调用compact，并不能清除 array 中的 NULL。
    [array compact];
    NSLog(@"compact array.count = %ld",array.count);

    NSMutableSet *set = [NSMutableSet setWithObjects:@(0),@(1),@(2),@(3),@(4),@(10),@(11),@(12),@(13),@(14), nil];
    [set enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        [set removeObject:obj]; // 调用 remove 方法，并不会引起 crash
    }];
    NSLog(@"remove set.count = %ld",set.count);

}

@end
