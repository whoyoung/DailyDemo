//
//  CustomNotificationCenter.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/7/3.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "CustomNotificationCenter.h"
#import <UIKit/UIKit.h>

@interface CustomNotificationCenter ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSPointerArray *> *observerDict;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableSet<CustomObserverInfo *> *> *observerInfoDict;

@property (nonatomic, strong) NSLock *lock;

@end

@implementation CustomNotificationCenter

+ (instancetype)defaultCenter {
    static CustomNotificationCenter *center;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[CustomNotificationCenter alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:center selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    });
    return center;
}

- (NSMutableDictionary<NSString *,NSPointerArray *> *)observerDict {
    if (!_observerDict) {
        _observerDict = [NSMutableDictionary dictionary];
    }
    return _observerDict;
}

- (NSMutableDictionary<NSString *,NSMutableSet<CustomObserverInfo *> *> *)observerInfoDict {
    if (!_observerInfoDict) {
        _observerInfoDict = [NSMutableDictionary dictionary];
    }
    return _observerInfoDict;
}

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject {
    if (!aName || !aName.length || !observer) {
        return;
    }
    [self.lock lock];
    NSPointerArray *array = [self.observerDict objectForKey:aName];
    if (!array) {
        array = [NSPointerArray weakObjectsPointerArray];
        [self.observerDict setObject:array forKey:aName];
    }
    BOOL hasExisted = [self hasExistedObserver:observer pointerArray:array];
    if (!hasExisted) {
        [array addPointer:(void *)observer];
    }
    
    CustomObserverInfo *info = [[CustomObserverInfo alloc] initWithObserver:observer selector:aSelector name:aName object:anObject];
    if (![self hasExistedObserverInfo:info]) {
        NSMutableSet *set = [self.observerInfoDict objectForKey:aName];
        if (!set) {
            set = [NSMutableSet set];
            [self.observerInfoDict setObject:set forKey:aName];
        }
        [set addObject:info];
    }
    [self.lock unlock];
}

- (void)addObserverForName:(nullable NSNotificationName)aName observer:(nullable id)observer queue:(nullable NSOperationQueue *)queue usingBlock:(void (^)(CustomObserverInfo *info))block {
    if (!aName || !aName.length || !observer) {
        return;
    }
    [self.lock lock];
    NSPointerArray *array = [self.observerDict objectForKey:aName];
    if (!array) {
        array = [NSPointerArray weakObjectsPointerArray];
        [self.observerDict setObject:array forKey:aName];
    }
    BOOL hasExisted = [self hasExistedObserver:observer pointerArray:array];
    if (!hasExisted) {
        [array addPointer:(void *)observer];
    }
    
    CustomObserverInfo *info = [[CustomObserverInfo alloc] initWithObserver:observer name:aName queue:queue block:block];
    if (![self hasExistedObserverInfo:info]) {
        NSMutableSet *set = [self.observerInfoDict objectForKey:aName];
        if (!set) {
            set = [NSMutableSet set];
            [self.observerInfoDict setObject:set forKey:aName];
        }
        [set addObject:info];
    }
    [self.lock unlock];
}

- (BOOL)hasExistedObserver:(id)observer pointerArray:(NSPointerArray *)array {
    BOOL existed = NO;
    for (id tempObserver in array) {
        if (tempObserver == observer) {
            existed = YES;
            break;
        }
    }
    return existed;
}

- (BOOL)hasExistedObserverInfo:(CustomObserverInfo *)newInfo {
    NSMutableSet *set = [self.observerInfoDict objectForKey:newInfo.name];
    if (!set || !set.count) {
        return NO;
    }
    for (CustomObserverInfo *info in set) {
        if ([info isEqual:newInfo]) {
            return YES;
        }
    }
    return NO;
}

- (void)postNotification:(NSNotification *)notification {
    [self postNotificationName:notification.name object:notification.object userInfo:notification.userInfo];
}

- (void)postNotificationName:(NSNotificationName)aName {
    [self postNotificationName:aName object:nil userInfo:nil];
}

- (void)postNotificationName:(NSNotificationName)aName object:(nullable id)anObject {
    [self postNotificationName:aName object:anObject userInfo:nil];
}

- (void)postNotificationName:(NSNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo {
    [self.lock lock];
    NSPointerArray *pointerA = [self.observerDict objectForKey:aName];
    if (!pointerA || !pointerA.allObjects.count) {
        [self.lock unlock];
        return;
    }
    NSMutableSet *set = [self.observerInfoDict objectForKey:aName];
    if (!set || !set.count) {
        [self.lock unlock];
        return;
    }
    for (id observer in pointerA) {
        for (CustomObserverInfo *info in set) {
            if (info.observer == observer && info.object == anObject) {
                if (info.aSelector) {
                    NSString *selString = NSStringFromSelector(info.aSelector);
                    if ([selString hasSuffix:@":"]) {
                        info.userInfo = aUserInfo;
                    }
                    if ([observer respondsToSelector:info.aSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        [observer performSelector:info.aSelector withObject:info];
#pragma clang diagnostic pop
                    }
                } else if (info.block) {
                    info.userInfo = aUserInfo;
                    if (info.queue) {
                        __weak typeof(info) weakInfo = info;
                        [info.queue addOperationWithBlock:^{
                            if (weakInfo) {
                                __strong typeof(weakInfo) strongInfo = weakInfo;
                                strongInfo.block(info);
                            }
                        }];
                    } else {
                        info.block(info);
                    }
                }
                
            }
        }
    }
    [self.lock unlock];
}

- (void)didReceiveMemoryWarning {
    @synchronized (self) {
        [self cleanObserverDict];
        [self cleanObserverInfoDict];
    };
}

- (void)cleanObserverDict {
    if (!self.observerDict.count) {
        return;
    }
    [self.lock lock];
    [self.observerDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSPointerArray * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.count) {
            [obj addPointer:NULL]; // 不加上这句的话，直接调用compact，并不能清除 array 中的 NULL。
            [obj compact];
        }
    }];
    [self.lock unlock];
}

- (void)cleanObserverInfoDict {
    if (!self.observerInfoDict.count) {
        return;
    }
    [self.lock lock];
    [self.observerInfoDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableSet<CustomObserverInfo *> * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(CustomObserverInfo * _Nonnull infoObj, BOOL * _Nonnull stop) {
            if (!infoObj.observer) {
                [obj removeObject:infoObj];
                infoObj = nil;
            }
        }];
    }];
    [self.lock unlock];
}

- (void)removeObserver:(id)observer {
    [self removeObserver:observer name:nil object:nil];
}

/*
 伪代码：
 if (observer == nil ) return;
 if (aName != nil) {
     在 observerDict 中 以 aName 为 key 的 NSPointerArray
         if (NSPointerArray 中 有 pointer 和 observer 相同) {
             在 observerInfoDict 中查找 aName 和 observer 都相同的 CustomObserverInfo
                 if (CustomObserverInfo.object == anObject) {
                     将 CustomObserverInfo 从 observerInfoDict 中移除
                 } else {
                     // 因为 CustomObserverInfo.object != anObject，所以 observerDict 不能移除 pointer
                 }
                 if (所以的 CustomObserverInfo.object == anObject) {
                     将 pointer 从 observerDict 中移除
                 }
         }
 } else if (!aName && anObject) {
     在 observerInfoDict 中遍历 CustomObserverInfo
         if (CustomObserverInfo.observer == observer && CustomObserverInfo.object == anObject) {
             将 CustomObserverInfo 从 observerInfoDict 中移除
         }
 } else if (!aName && !anObject) {
     移除 observerDict.NSPointerArray 中，所有 pointer == observer 的 pointer
     移除 observerInfoDict.NSMutableSet<CustomObserverInfo *> 中，所有 CustomObserverInfo.observer == observer 的 CustomObserverInfo.observer
 }
 */
- (void)removeObserver:(id)observer name:(nullable NSNotificationName)aName object:(nullable id)anObject {
    if (!observer) {
        return;
    }
    [self.lock lock];
    [self.observerDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSPointerArray * _Nonnull obj, BOOL * _Nonnull stop) {
        if (aName && [key isEqualToString:aName]) { // 通知名一致
            for (NSInteger i = obj.count - 1; i >= 0; i--) {
                id pointer = [obj pointerAtIndex:i];
                if (observer == pointer) { // 观察者一致
                    NSMutableSet *set = [self.observerInfoDict objectForKey:aName]; // 观察信息集合
                    __block BOOL isInfoSame = YES;
                    if (set) {
                        [set enumerateObjectsUsingBlock:^(CustomObserverInfo * _Nonnull obj, BOOL * _Nonnull stop) {
                            if (obj.observer == observer) {
                                if (obj.object == anObject) { // 观察信息完全一致，则移除该观察信息
                                    [set removeObject:obj];
                                } else { // 观察信息不完全一致，则保留该观察信息
                                    isInfoSame = NO;
                                }
                            }
                        }];
                        if (!set.count) { // 无观察者信息了，则观察者信息字典移除该通知
                            [self.observerInfoDict removeObjectForKey:aName];
                        }
                    }
                    if (isInfoSame) { // 观察者相同，且观察信息完全一致
                        [obj removePointerAtIndex:i]; // 观察者数组移除该观察者
                        if (!obj.allObjects.count) { // 如果观察者数组里非 NULL 对象个数为零，则观察者字典移除该通知
                            [self.observerDict removeObjectForKey:aName];
                        }

                    }
                }
            }
        } else if (!aName && anObject) {
            [self.observerInfoDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableSet<CustomObserverInfo *> * _Nonnull set, BOOL * _Nonnull stop) {
                [set enumerateObjectsUsingBlock:^(CustomObserverInfo * _Nonnull obj, BOOL * _Nonnull stop) {
                    if (obj.observer == observer && obj.object == anObject) { // 观察者信息一致
                        [set removeObject:obj];
                    }
                }];
                if (!set.count) { // 无观察者信息了，则观察者信息字典移除该通知
                    [self.observerInfoDict removeObjectForKey:key];
                }
            }];
            
        } else if (!aName && !anObject) {
            [self.observerDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSPointerArray * _Nonnull obj, BOOL * _Nonnull stop) {
                for (NSInteger i = obj.count - 1; i >= 0; i--) {
                    id pointer = [obj pointerAtIndex:i];
                    if (observer == pointer) { // 观察者一致
                        [obj removePointerAtIndex:i]; // 观察者数组移除该观察者
                    }
                }
                if (!obj.allObjects.count) { // 如果观察者数组里非 NULL 对象个数为零，则观察者字典移除该通知
                    [self.observerDict removeObjectForKey:key];
                }
            }];
            
            [self.observerInfoDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableSet<CustomObserverInfo *> * _Nonnull set, BOOL * _Nonnull stop) {
                [set enumerateObjectsUsingBlock:^(CustomObserverInfo * _Nonnull obj, BOOL * _Nonnull stop) {
                    if (obj.observer == observer) { // 观察者一致
                        [set removeObject:obj];
                    }
                }];
                if (!set.count) { // 无观察者信息了，则观察者信息字典移除该通知
                    [self.observerInfoDict removeObjectForKey:key];
                }
            }];
        }
    }];
    [self.lock unlock];
}

- (NSLock *)lock {
    if (!_lock) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}

@end
