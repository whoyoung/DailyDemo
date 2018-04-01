//
//  IsEqualObject.m
//  YHDailyDemo
//
//  Created by young on 2018/4/1.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "IsEqualObject.h"

@implementation IsEqualObject
- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        self->_name = name;
    }
    return self;
}
@end
