//
//  NextViewController.m
//  OCDemo
//
//  Created by young on 2022/7/6.
//

#import "NextViewController.h"
#import <Foundation/Foundation.h>
#import "FollowStatusSyncManager.h"
#import "ThirdViewController.h"

@interface NextViewController ()
@property (nonatomic, strong) FollowStatusSyncPlugin *plugin;

@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];
    _plugin = [FollowStatusSyncPlugin new];
    __weak typeof(self) weakSelf = self;
    _plugin.block = ^(FollowStatusSync * _Nonnull status) {
        weakSelf.view.backgroundColor = [UIColor redColor];
        NSLog(@"next page = %lu", (unsigned long)status.status);
    };
    
    [[FollowStatusSyncManager shareManager] registerPlugin:_plugin];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"to third page" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(100, 100, 100, 100);
    [btn setBackgroundColor:[UIColor whiteColor]];
    [btn addTarget:self action:@selector(toThirdPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)toThirdPage {
    ThirdViewController *vc = [ThirdViewController new];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
