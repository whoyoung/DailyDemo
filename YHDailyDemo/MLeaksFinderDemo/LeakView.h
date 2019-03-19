//
//  LeakView.h
//  YHDailyDemo
//
//  Created by young on 2018/6/10.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeakView : UIView

@property (nonatomic, copy) void (^block)(void);

- (UIColor *)changeBackgroundColor:(void (^)(UIColor *color))block;
@end
