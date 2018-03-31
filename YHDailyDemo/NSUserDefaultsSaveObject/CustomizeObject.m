//
//  CustomizeObject.m
//  YHDailyDemo
//
//  Created by young on 2018/3/31.
//  Copyright © 2018年 杨虎. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CustomizeObject.h"

@implementation CustomizeObject
- (instancetype)initWithName:(NSString *)name height:(CGFloat)height {
    if (self = [super init]) {
        self.name = name;
        self.height = height;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:@(self.height) forKey:@"height"];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.height = [[aDecoder decodeObjectForKey:@"height"] floatValue];
    }
    return self;
}
@end
