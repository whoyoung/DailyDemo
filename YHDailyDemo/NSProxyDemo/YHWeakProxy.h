//
//  YHWeakProxy.h
//  YHDailyDemo
//
//  Created by young on 2018/3/18.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHWeakProxy : NSProxy
+ (instancetype)proxyWithTarget:(nonnull id)target;
- (instancetype)initWithTarget:(nonnull id)target;
@end
