//
//  AssignObjectDemoViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/3/25.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "AssignObjectDemoViewController.h"


@implementation TestObject

@end

@interface AssignObjectDemoViewController ()

@end

@implementation AssignObjectDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    TestObject *obj = [TestObject new];
    self.obj = obj;
    self.obj.num = 1;
    NSLog(@"%@",self.obj);
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.obj.num = 2;
    [super touchesBegan:touches withEvent:event];
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
