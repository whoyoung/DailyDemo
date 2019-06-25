//
//  WeakIVarDataSource.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/6/10.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "WeakIVarDataSource.h"

@interface WeakIVarDataSource ()

@property (nonatomic, weak) UIView *superView;

@property (nonatomic, copy) NSString *superString;

@end

@implementation WeakIVarDataSource

- (instancetype)init NS_UNAVAILABLE {
    NSAssert(NO, @"Please use initWithTableView:");
    return nil;
}

- (instancetype)initWithSuperView:(UIView *)superView {
    self = [super init];
    if (self) {
//        self.superView = superView;
        _superView = superView;
    }
    return self;
}

- (instancetype)initWithSuperString:(NSString *)superString {
    self = [super init];
    if (self) {
        //        self.superView = superView;
        _superString = superString;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s dealloc ====",__func__);
}

@end
