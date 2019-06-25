//
//  WeakIVarViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/6/10.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "WeakIVarViewController.h"
#import "WeakIVarDataSource.h"

@interface WeakIVarViewController ()

@property (nonatomic, strong) WeakIVarDataSource *dataSource;

@property (nonatomic, copy) NSString *testString;

@end

@implementation WeakIVarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.dataSource = [[WeakIVarDataSource alloc] initWithSuperView:self];
    
    self.testString = @"testString";
    self.dataSource = [[WeakIVarDataSource alloc] initWithSuperString:self.testString];
}

- (void)dealloc {
    NSLog(@"%s dealloc ====",__func__);
}

@end
