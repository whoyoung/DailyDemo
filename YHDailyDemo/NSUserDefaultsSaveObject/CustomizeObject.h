//
//  CustomizeObject.h
//  YHDailyDemo
//
//  Created by young on 2018/3/31.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomizeObject : NSObject<NSCoding>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CGFloat height;

- (instancetype)initWithName:(NSString *)name height:(CGFloat)height;
@end
