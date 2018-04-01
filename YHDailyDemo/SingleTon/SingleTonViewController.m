//
//  SingleTonViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/4/1.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "SingleTonViewController.h"
#import "SingleTonObject.h"
@interface SingleTonViewController ()

@end

@implementation SingleTonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    SingleTonObject *obj0 = [SingleTonObject shareInstance];
    SingleTonObject *obj1 = [[SingleTonObject alloc] init];
    SingleTonObject *obj2 = [[SingleTonObject alloc] init];

    NSLog(@"%p; %p; %p",obj0,obj1,obj2);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
