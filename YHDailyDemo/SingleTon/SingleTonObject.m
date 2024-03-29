//
//  SingleTonObject.m
//  YHDailyDemo
//
//  Created by young on 2018/4/1.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "SingleTonObject.h"
static SingleTonObject *singleTon = nil;
@implementation SingleTonObject
+ (instancetype)shareInstance {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!singleTon) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            singleTon = [super allocWithZone:zone];
        });
    }
    return singleTon;
}
- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [super init];
    });
    return singleTon;
}

- (void)singletonParam:(NSString *)a block:(void (^)(NSString *str))block {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(5);
        block([NSString stringWithFormat:@"%@_str",a]);

    });
}
@end
