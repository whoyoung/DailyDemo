//
//  YHMultiInheritProxy.m
//  YHDailyDemo
//
//  Created by young on 2018/3/18.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "YHMultiInheritProxy.h"
#import <objc/runtime.h>

@interface YHMultiInheritProxy()
@property (nonatomic, strong) NSMutableDictionary *dict;
@end
@implementation YHMultiInheritProxy
+ (instancetype)purchase {
    return [[self alloc] init];
}
- (instancetype)init {
    _dict = [NSMutableDictionary dictionaryWithCapacity:0];
    YHBookProvider *bookP = [[YHBookProvider alloc] init];
    YHClothesProvider *clothesP = [[YHClothesProvider alloc] init];
    [self registerMethodsWithTarget:bookP];
    [self registerMethodsWithTarget:clothesP];
    return self;
}
     
- (void)registerMethodsWithTarget:(id)target {
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList([target class], &methodCount);
    for (NSUInteger i=0;i<methodCount;i++) {
        Method m = methodList[i];
        NSString *methodName = NSStringFromSelector(method_getName(m));
        [_dict setObject:target forKey:methodName];
    }
    free(methodList);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    id target = [_dict valueForKey:NSStringFromSelector(sel)];
    if (target && [target respondsToSelector:sel]) {
        return [target methodSignatureForSelector:sel];
    } else {
        return [super methodSignatureForSelector:sel];
    }
}
- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL sel = invocation.selector;
    id target = [_dict valueForKey:NSStringFromSelector(sel)];
    if (target && [target respondsToSelector:sel]) {
        return [invocation invokeWithTarget:target];
    } else {
        return [super forwardInvocation:invocation];
    }
}
@end
