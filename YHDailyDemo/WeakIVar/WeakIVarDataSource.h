//
//  WeakIVarDataSource.h
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/6/10.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeakIVarDataSource : NSObject

- (instancetype)initWithSuperView:(UIView *)superView NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithSuperString:(NSString *)superString NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
