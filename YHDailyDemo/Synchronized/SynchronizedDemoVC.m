//
//  SynchronizedDemoVC.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/6/25.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "SynchronizedDemoVC.h"

@interface SynchronizedDemoVC ()

@property (nonatomic, strong) NSMutableDictionary *dict;

@end

@implementation SynchronizedDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dict = [NSMutableDictionary dictionary];
    for (NSUInteger i=0; i<1000; i++) {
        [self.dict setObject:@(i) forKey:@(i).stringValue];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (NSUInteger i=0; i<1000; i++) {
            NSUInteger key = arc4random_uniform(999);
            @synchronized (self) {
                [self.dict removeObjectForKey:@(key).stringValue];
            }
        }
    });
    
    for (NSUInteger i=0; i<1000; i++) {
        @synchronized (self) {
            NSDictionary *newDict = [self.dict copy];
            [self.dict removeObjectForKey:@(i).stringValue];
            [[NSUserDefaults standardUserDefaults] setObject:newDict forKey:@"dict"];
        }
    
    }
}

@end
