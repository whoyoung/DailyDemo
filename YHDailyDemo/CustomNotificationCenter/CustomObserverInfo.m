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

@end
