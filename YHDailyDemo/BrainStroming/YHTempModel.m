//
//  YHTempModel.m
//  YHDailyDemo
//
//  Created by young on 2019/9/7.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "YHTempModel.h"

@implementation YHTempModel


+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    return NO;
}

- (id)valueForUndefinedKey:(NSString *)key {
    return @"";
}

@end
