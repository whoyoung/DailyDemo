//
//  LockDemoViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/3/22.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "LockDemoViewController.h"

@interface LockDemoViewController ()
@property (nonatomic, strong) NSArray *datas;
@end

@implementation LockDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _datas = @[@"recursiveLock"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = self.datas[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SEL sel = NSSelectorFromString(self.datas[indexPath.row]);
    [self performSelector:sel];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)recursiveLock {
    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
//    NSLock *lock = [[NSLock alloc] init];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        static void (^RecursiveLock)(int);
        RecursiveLock = ^(int value){
            [lock lock];
            if (value > 0) {
                NSLog(@"%d",value);
                sleep(1);
                RecursiveLock(--value);
            }
            [lock unlock];
            NSLog(@"after Lock");

        };
            RecursiveLock(3);
    });
}
@end
