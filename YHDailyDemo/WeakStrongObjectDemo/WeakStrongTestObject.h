//
//  WeakStrongTestObject.h
//  YHDailyDemo
//
//  Created by 杨虎 on 2021/1/26.
//  Copyright © 2021 杨虎. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeakStrongTestObject : UIView

@property (nonatomic, copy) void (^myBlock)();

- (void)changeColor:(void (^)(UIColor *color))Block;

@end

NS_ASSUME_NONNULL_END
