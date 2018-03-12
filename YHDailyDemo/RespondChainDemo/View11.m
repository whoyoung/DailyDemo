//
//  View11.m
//  YHDailyDemo
//
//  Created by young on 2018/3/12.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "View11.h"

@implementation View11
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    NSLog(@"view2 hit test");
    return [super hitTest:point withEvent:event];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    NSLog(@"view2 point inside");
    return [super pointInside:point withEvent:event];
}
@end
