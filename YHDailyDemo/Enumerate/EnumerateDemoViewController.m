//
//  EnumerateDemoViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/7/3.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "EnumerateDemoViewController.h"

@interface EnumerateDemoViewController ()

@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, assign) NSUInteger count;
@end

@implementation EnumerateDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.count = 1000;
    self.array = [NSMutableArray arrayWithCapacity:self.count];
    for (NSInteger i=0; i<self.count; i++) {
        [self.array addObject:@(i)];
    }
    
    NSArray *titles = @[@"enumerateMethod",@"dispatchApplyMethod",@"forInMethod",@"forMethod"];
    for (NSUInteger i=0; i<titles.count;i++) {
        NSString *title = titles[i];
        UIButton *btn = [self testBtn:title];
        btn.frame = CGRectMake(40, 80+(40+20)*i, [UIScreen mainScreen].bounds.size.width - 80, 40);
    }
}

- (UIButton *)testBtn:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.layer.cornerRadius = 20;
    btn.layer.masksToBounds = YES;
    [btn setBackgroundColor:[UIColor lightGrayColor]];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:NSSelectorFromString(title) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
}

- (void)enumerateMethod {
    CFAbsoluteTime before = CFAbsoluteTimeGetCurrent();
    [self.array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"idx = %ld",idx); // 乱序遍历
    }];
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent() - before;
    NSLog(@"enumerateMethod respend time = %f",time); // respend time = 0.255736
}

- (void)dispatchApplyMethod {
    CFAbsoluteTime before = CFAbsoluteTimeGetCurrent();
    dispatch_apply(1000, dispatch_get_global_queue(0, 0), ^(size_t idx) {
        NSLog(@"idx = %ld",idx); // 顺序遍历
    });
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent() - before;
    NSLog(@"dispatchApplyMethod respend time = %f",time); // respend time = 0.146089
}

- (void)forInMethod {
    CFAbsoluteTime before = CFAbsoluteTimeGetCurrent();
    for (NSNumber *number in self.array) {
        NSLog(@"idx = %ld",number.integerValue); // 顺序遍历
    }
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent() - before;
    NSLog(@"forInMethod respend time = %f",time); // respend time = 0.255772
}

- (void)forMethod {
    CFAbsoluteTime before = CFAbsoluteTimeGetCurrent();
    for (NSInteger i = 0; i<1000; i++) {
        NSLog(@"idx = %ld",[self.array[i] integerValue]); // 顺序遍历
    }
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent() - before;
    NSLog(@"forMethod respend time = %f",time); // respend time = 0.275537
}

@end
