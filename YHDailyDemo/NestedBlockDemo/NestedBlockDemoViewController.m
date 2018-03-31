//
//  NestedBlockDemoViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/3/31.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "NestedBlockDemoViewController.h"

@interface NestedBlockDemoViewController ()
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *fullName;
@end

@implementation NestedBlockDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    __weak typeof(self) weakSelf = self;
    self.blockB = ^(NSString *name, BlockA blockA) {
        __strong typeof(self) strongSelf = weakSelf;
        NSLog(@"first name =====%@",name);
        strongSelf.firstName = name;
        if (blockA) {
            strongSelf.blockA = blockA;
            strongSelf.blockA(strongSelf.firstName); //此处strongSelf不需要再次使用__weak,因为strongSelf的作用域只存在于blockB的内部，出了blockB作用域之后就会被释放
        }
    };
    
    self.blockB(@"hu", ^(NSString *firstName) {
        weakSelf.fullName = [NSString stringWithFormat:@"%@_yang",firstName];
        NSLog(@"full name == %@",weakSelf.fullName);
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (self.blockA) {
        self.blockA(@"lalallal");
    }
}
- (void)dealloc {
    NSLog(@"i am dead!");
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
