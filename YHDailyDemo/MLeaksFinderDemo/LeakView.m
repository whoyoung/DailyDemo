//
//  LeakView.m
//  YHDailyDemo
//
//  Created by young on 2018/6/10.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "LeakView.h"

@implementation LeakView
- (UIColor *)changeBackgroundColor:(void (^)(UIColor *color))block {
    block([UIColor blueColor]);
    return [UIColor blueColor];
}
@end
