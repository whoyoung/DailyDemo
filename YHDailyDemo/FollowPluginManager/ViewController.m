//
//  FollowPluginViewController.m
//  OCDemo
//
//  Created by young on 2022/6/17.
//

#import "FollowPluginViewController.h"
#import "NextViewController.h"
#import "FollowStatusSyncManager.h"


@interface FollowPluginViewController ()

@property (nonatomic, strong) FollowStatusSyncPlugin *plugin;

@end

@implementation FollowPluginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];
    _plugin = [FollowStatusSyncPlugin new];
    __weak typeof(self) weakSelf = self;
    _plugin.block = ^(FollowStatusSync * _Nonnull status) {
        weakSelf.view.backgroundColor = [UIColor redColor];
        NSLog(@"first page = %lu", (unsigned long)status.status);
    };
    
    [[FollowStatusSyncManager shareManager] registerPlugin:_plugin];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    NextViewController *vc = [NextViewController new];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
