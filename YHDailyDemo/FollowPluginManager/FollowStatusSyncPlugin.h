//
//  FollowStatusSyncPlugin.h
//  OCDemo
//
//  Created by young on 2022/7/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FollowStatus) {
    FollowStatusUnfollow,
    FollowStatusFollowing,
    FollowStatusMutulFollow
};

@interface FollowStatusSync : NSObject

@property (nonatomic, assign) FollowStatus status;

@property (nonatomic, copy) NSString *objId;

@end

typedef void(^syncBlock)(FollowStatusSync *status);

@interface FollowStatusSyncPlugin : NSObject

//@property (nonatomic, copy, nullable) void (^syncBlock)(FollowStatus *status);

@property (nonatomic, copy, nullable) syncBlock block;


@end

NS_ASSUME_NONNULL_END
