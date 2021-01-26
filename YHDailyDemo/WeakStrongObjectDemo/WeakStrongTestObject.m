//
//  WeakStrongTestObject.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2021/1/26.
//  Copyright © 2021 杨虎. All rights reserved.
//

#import "WeakStrongTestObject.h"

@implementation WeakStrongTestObject

- (void)changeColor:(void (^)(UIColor *color))Block {
    Block([UIColor redColor]);
    
}


- (void)dealloc {
    NSLog(@"WeakStrongTestObject is dead");
}

@end
