//
//  ForInDeleteViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/1/28.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "ForInDeleteViewController.h"

@interface ForInDeleteViewController ()

@end

@implementation ForInDeleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray *array = @[@1,@2,@3,@4,@5,@6].mutableCopy;
    for (NSNumber *number in array) {
        NSLog(@"number ==== %ld",(long)number.integerValue);
        if (number.integerValue == 2) {
            [array removeObject:number];
        } else if (number.integerValue == 3) {
            [array removeObject:number];
        }
    }
    // 结论 forin 时删除 子对象会崩溃
}


@end
