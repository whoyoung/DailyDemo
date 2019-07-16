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
}

- (void)addObserverForName:(nullable NSNotificationName)aName observer:(nullable id)observer queue:(nullable NSOperationQueue *)queue usingBlock:(void (^)(CustomObserverInfo *info))block {
    if (!aName || !aName.length || !observer) {
        return;
    }
    
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
    NSPointerArray *pointerA = [self.observerDict objectForKey:aName];
    if (!pointerA || !pointerA.allObjects.count) {
        return;
    }
    NSMutableSet *set = [self.observerInfoDict objectForKey:aName];
    if (!set || !set.count) {
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
    [self.observerDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSPointerArray * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.count) {
            [obj addPointer:NULL]; // 不加上这句的话，直接调用compact，并不能清除 array 中的 NULL。
            [obj compact];
        }
    }];
}

- (void)cleanObserverInfoDict {
    if (!self.observerInfoDict.count) {
        return;
    }
    [self.observerInfoDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableSet<CustomObserverInfo *> * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(CustomObserverInfo * _Nonnull infoObj, BOOL * _Nonnull stop) {
            if (!infoObj.observer) {
                [obj removeObject:infoObj];
                infoObj = nil;
            }
        }];
    }];
}

@end
