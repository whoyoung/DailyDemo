//
//  ScrollViewAndLongPressGestureViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/3/25.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "ScrollViewAndLongPressGestureViewController.h"

@interface ScrollViewAndLongPressGestureViewController () <UIScrollViewDelegate>



@end

@implementation ScrollViewAndLongPressGestureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200)];
    scroll.backgroundColor = [UIColor orangeColor];
    scroll.delegate = self;
    scroll.contentSize = CGSizeMake(2 * [UIScreen mainScreen].bounds.size.width, 200);
    [self.view addSubview:scroll];
    
    UILongPressGestureRecognizer *longG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressHandler:)];
    [scroll addGestureRecognizer:longG];
    
    // 结论：长按手势生效时，移动手指的位置，不会触发 scrollView 的 scrollViewDidScroll：代理方法
}

- (void)pressHandler:(UILongPressGestureRecognizer *)gesture {
    CGPoint p = [gesture locationInView:self.view];
    NSLog(@"p.x === %f",p.x);

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollView.contentOffset.x === %f",scrollView.contentOffset.x);
}

@end
