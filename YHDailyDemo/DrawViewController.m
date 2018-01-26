//
//  DrawViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/1/19.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "DrawViewController.h"
#import "CoreGraphicDrawView.h"
#import "CoreAnimationDrawView.h"
@interface DrawViewController ()
@property (nonatomic, strong) CoreGraphicDrawView *coreGraphicView;
@property (nonatomic, strong) CoreAnimationDrawView *coreAnimationView;
@end

@implementation DrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *coreGraphicBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.view.frame)-50, 150, 50)];
    [coreGraphicBtn setTitle:@"coreGraphic" forState:UIControlStateNormal];
    [coreGraphicBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [coreGraphicBtn addTarget:self action:@selector(showCoreGraphicView) forControlEvents:UIControlEventTouchUpInside];
    [coreGraphicBtn setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:coreGraphicBtn];
    
    UIButton *coreAnimationBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.view.frame)-150-10, CGRectGetMaxY(self.view.frame)-50, 150, 50)];
    [coreAnimationBtn setTitle:@"coreAnimation" forState:UIControlStateNormal];
    [coreAnimationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [coreAnimationBtn addTarget:self action:@selector(showCoreAnimationView) forControlEvents:UIControlEventTouchUpInside];
    [coreAnimationBtn setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:coreAnimationBtn];
}
- (void)showCoreGraphicView {
    self.coreAnimationView.hidden = YES;
    self.coreGraphicView.hidden = NO;
    [self.coreGraphicView setNeedsDisplay];
}
- (UIView *)coreGraphicView {
    if (!_coreGraphicView) {
        _coreGraphicView = [[CoreGraphicDrawView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64-50)];
        [self.view addSubview:_coreGraphicView];
    }
    return _coreGraphicView;
}

- (void)showCoreAnimationView {
    self.coreGraphicView.hidden = YES;
    self.coreAnimationView.hidden = NO;
    [self.coreAnimationView setNeedsLayout];
}
- (UIView *)coreAnimationView {
    if (!_coreAnimationView) {
        _coreAnimationView = [[CoreAnimationDrawView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64-50)];
        [self.view addSubview:_coreAnimationView];
    }
    return _coreAnimationView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
