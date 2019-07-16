//
//  CustomObserverInfo.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/7/3.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "CustomObserverInfo.h"

@implementation CustomObserverInfo

- (instancetype)initWithObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject {
    if (!aName || !aName.length) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.observer = observer;
        self.aSelector = aSelector;
        self.name = aName;
        self.object = anObject;
    }
    return self;
}

- (instancetype)initWithObserver:(id)observer name:(nullable NSNotificationName)aName queue:(nullable NSOperationQueue *)queue block:(void (^)(CustomObserverInfo *info))block {
    if (!aName || !aName.length) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.observer = observer;
        self.name = aName;
        self.block = block;
        self.queue = queue;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (!object || ![object isKindOfClass:[CustomObserverInfo class]]) {
        return NO;
    }
    CustomObserverInfo *newInfo = (CustomObserverInfo *)object;
    if (self.observer == newInfo.observer && self.object == newInfo.object && self.aSelector == newInfo.aSelector && self.queue == newInfo.queue && self.block == newInfo.block) {
        return YES;
    }
    return NO;
}

@end
