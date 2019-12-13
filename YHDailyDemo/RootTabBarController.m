//
//  RootTabBarController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/12/11.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "RootTabBarController.h"
#import "NSObject+ViewTool.h"

@interface RootTabBarController ()

@end

@implementation RootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (BOOL)shouldAutorotate {
    UIViewController *currentVC = [NSObject currentViewController];
    if (currentVC != self && [currentVC respondsToSelector:@selector(shouldAutorotate)]) {
        return [currentVC shouldAutorotate];
    }
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *currentVC = [NSObject currentViewController];
    if (currentVC != self && [currentVC respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return [currentVC supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)prefersStatusBarHidden {
    UIViewController *currentVC = [NSObject currentViewController];
    if (currentVC != self && [currentVC respondsToSelector:@selector(prefersStatusBarHidden)]) {
        return [currentVC prefersStatusBarHidden];
    }
    return NO;
}

@end
