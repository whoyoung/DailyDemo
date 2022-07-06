//
//  ThirdViewController.m
//  OCDemo
//
//  Created by young on 2022/7/6.
//

#import "ThirdViewController.h"
#import "FollowStatusSyncManager.h"

@interface ThirdViewController ()

@property (nonatomic, strong) FollowStatusSyncPlugin *plugin;

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    _plugin = [FollowStatusSyncPlugin new];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    FollowStatusSync *sync = [FollowStatusSync new];
    sync.status = FollowStatusFollowing;
    sync.objId = @"test id";
    [[FollowStatusSyncManager shareManager] sync:_plugin status:sync];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
