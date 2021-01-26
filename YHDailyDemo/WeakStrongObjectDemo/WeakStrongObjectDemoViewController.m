//
//  WeakStrongObjectDemoViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/3/25.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "WeakStrongObjectDemoViewController.h"
#import "WeakStrongTestObject.h"

typedef void(^TestBlock)(void);

@interface WeakStrongObjectDemoViewController ()
@property (nonatomic, copy) TestBlock block;
@property (nonatomic, copy) NSString *testStr;
@property (nonatomic, assign) NSUInteger interval;

@property (nonatomic) WeakStrongTestObject *testView;
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

- (void)test3Block { // 无内存泄露
    self.interval = 3;
    [UIView animateWithDuration:self.interval animations:^{
        self.view.backgroundColor = [UIColor redColor];
    }];
}

- (void)test4Block { // 无内存泄露
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.view.backgroundColor = [UIColor redColor];
    });
}

- (void)test5Block {// 无内存泄露
    self.testView = [[WeakStrongTestObject alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.view addSubview:self.testView];
    self.testView.backgroundColor = [UIColor blueColor];
    self.testView.center = self.view.center;
    [self.testView changeColor:^(UIColor * _Nonnull color) {
        self.testView.backgroundColor = color;
    }];
}

- (void)test6Block {// 无内存泄露
    WeakStrongTestObject *testV = [[WeakStrongTestObject alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    testV.backgroundColor = [UIColor blueColor];
    [self.view addSubview:testV];
    testV.center = self.view.center;
    [testV changeColor:^(UIColor * _Nonnull color) {
        testV.backgroundColor = color;
    }];
}

- (void)test7Block {// 有内存泄露
    self.testView = [[WeakStrongTestObject alloc] init];
    self.testView.myBlock = ^{
        NSLog(@"%p",self);
    };
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self testBlock];
    
//    [self test1Block];
    
//    [self test2Block];
//    [self test4Block];
//    [self test5Block];
//    [self test6Block];
    [self test7Block];
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
