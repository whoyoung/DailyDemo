//
//  WeakStrongObjectDemoViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/3/25.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "WeakStrongObjectDemoViewController.h"

typedef void(^TestBlock)(void);

@interface WeakStrongObjectDemoViewController ()
@property (nonatomic, copy) TestBlock block;
@property (nonatomic, copy) NSString *testStr;
@end

@implementation WeakStrongObjectDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.testStr = @"1";
}

- (void)testBlock {
    self.block = ^{
        self.testStr = @"2";
    };
        
    self.block();
}

- (void)test1Block {
    __weak typeof(self) weakSelf = self;
    self.block = ^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            weakSelf.testStr = @"2";
            //        sleep(10);
            [NSThread sleepForTimeInterval:10];
            NSLog(@"weakSelf.testStr=%@",weakSelf.testStr);
        });
        
    };
    
    self.block();
}

- (void)test2Block {
    __weak typeof(self) weakSelf = self;
    self.block = ^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.testStr = @"2";
            //        sleep(10);
            [NSThread sleepForTimeInterval:10];
            NSLog(@"weakSelf.testStr=%@",strongSelf.testStr);
        });
        
    };
    
    self.block();
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self testBlock];
    
//    [self test1Block];
//    [self.navigationController popViewControllerAnimated:YES];
    
    [self test2Block];
    [self.navigationController popViewControllerAnimated:YES];
    
    [super touchesBegan:touches withEvent:event];
}

- (void)dealloc {
    NSLog(@"i am dead");
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
