//
//  YHWeakProxy.m
//  YHDailyDemo
//
//  Created by young on 2018/3/18.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "YHWeakProxy.h"

@interface YHWeakProxy()
@property (nonatomic, weak) id target;
@end

@implementation YHWeakProxy
+ (instancetype)proxyWithTarget:(nonnull id)target {
    return [[self alloc] initWithTarget:target];
}
- (instancetype)initWithTarget:(nonnull id)target {
    _target = target;
    return self;
}
//- (id)forwardingTargetForSelector:(SEL)aSelector {
//    return self.target;
//}
- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL sel = invocation.selector;
    if ([self.target respondsToSelector:sel]) {
        [invocation invokeWithTarget:self.target];
    }
}
- (nullable NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.target methodSignatureForSelector:sel];
}
- (BOOL)respondsToSelector:(SEL)aSelector {
    return [self.target respondsToSelector:aSelector];
}
@end
