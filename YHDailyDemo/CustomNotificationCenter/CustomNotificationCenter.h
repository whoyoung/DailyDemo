//
//  CustomNotificationCenter.h
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/7/3.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomObserverInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface CustomNotificationCenter : NSObject

+ (instancetype)defaultCenter;

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject;

- (void)addObserverForName:(nullable NSNotificationName)name observer:(nullable id)observer queue:(nullable NSOperationQueue *)queue usingBlock:(void (^)(CustomObserverInfo *info))block;

- (void)postNotification:(NSNotification *)notification;

- (void)postNotificationName:(NSNotificationName)aName object:(nullable id)anObject;

- (void)postNotificationName:(NSNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo;

@end

NS_ASSUME_NONNULL_END
