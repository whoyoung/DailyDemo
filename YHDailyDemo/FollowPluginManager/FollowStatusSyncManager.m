//
//  FollowStatusSyncManager.m
//  OCDemo
//
//  Created by young on 2022/7/6.
//

#import "FollowStatusSyncManager.h"

@interface FollowStatusSyncManager ()

@property (nonatomic, strong) NSPointerArray *plugins;

@end

static FollowStatusSyncManager *manager;

@implementation FollowStatusSyncManager

+ (instancetype)shareManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[FollowStatusSyncManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.plugins = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

- (void)registerPlugin:(nullable FollowStatusSyncPlugin *)plugin {
    [self.plugins addPointer:(__bridge void * _Nullable)(plugin)];
}

- (void)sync:(nullable FollowStatusSyncPlugin *)plugin status:(FollowStatusSync *)status {
    NSArray *objs = self.plugins.allObjects;
    for (FollowStatusSyncPlugin *aPlugin in objs) {
        if ([aPlugin isEqual:plugin]) {
            continue;
        }
        if (aPlugin.block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                aPlugin.block(status);
            });
        }
    }
}

@end
