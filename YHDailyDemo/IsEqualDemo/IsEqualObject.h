//
//  IsEqualObject.h
//  YHDailyDemo
//
//  Created by young on 2018/4/1.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IsEqualObject : NSObject
@property (nonatomic, copy, readonly) NSString *name;
- (instancetype)initWithName:(NSString *)name;
@end
