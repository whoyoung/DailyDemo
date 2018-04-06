//
//  MultiCategoryViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/4/5.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "MultiCategoryViewController.h"
#import "NSString+append.h"
@interface MultiCategoryViewController ()

@end

@implementation MultiCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSString *str = [@"dd" stringByAppendingString]; //调用原类不存在的方法，需要引入分类的头文件
    NSString *subStr = [@"dd" substringFromIndex:0]; //调用原类存在的方法，不要需要引入分类的头文件
    
    //多个分类重写同一个方法，具体调用哪个分类的方法，与分类在build phase--compile source中分类的顺序相关
    NSLog(@"str ==== %@, subStr=====%@",str,subStr);
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
