//
//  RespondChainViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/3/12.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "RespondChainViewController.h"
#import "View1.h"
#import "View11.h"
@interface RespondChainViewController ()

@end

@implementation RespondChainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    View1 *v1 = [[View1 alloc] initWithFrame:CGRectMake(0, 64, 200, 400)];
    [self.view addSubview:v1];
    
    View11 *v11 = [[View11 alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
    [v1 addSubview:v11];
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
