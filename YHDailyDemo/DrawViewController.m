//
//  DrawViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/1/19.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "DrawViewController.h"
#import "CoreGraphicDrawView.h"
@interface DrawViewController ()
@property (nonatomic, strong) UIView *coreGraphicView;
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
    
    
}
- (void)showCoreGraphicView {
    [self.coreGraphicView setNeedsDisplay];
}
- (UIView *)coreGraphicView {
    if (!_coreGraphicView) {
        _coreGraphicView = [[CoreGraphicDrawView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64-50)];
        [self.view addSubview:_coreGraphicView];
    }
    return _coreGraphicView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
