//
//  FollowStatusSyncManager.h
//  OCDemo
//
//  Created by young on 2022/7/6.
//

#import <Foundation/Foundation.h>
#import "FollowStatusSyncPlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface FollowStatusSyncManager : NSObject

+ (instancetype)shareManager;

- (void)registerPlugin:(nullable FollowStatusSyncPlugin *)plugin;

- (void)sync:(nullable FollowStatusSyncPlugin *)plugin status:(FollowStatusSync *)status;

@end

NS_ASSUME_NONNULL_END
