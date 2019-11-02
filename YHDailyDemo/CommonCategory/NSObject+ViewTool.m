//
//  NSObject+ViewTool.m
//  YHDailyDemo
//
//  Created by young on 2019/11/2.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "NSObject+ViewTool.h"
#import "AppDelegate.h"

@implementation NSObject (ViewTool)

+ (UIViewController *)currentViewController {
    UIViewController *rootVC = ((AppDelegate *)([UIApplication sharedApplication].delegate)).window.rootViewController;
    return [self currentViewControllerFromVC:rootVC];
}

+ (UIViewController *)currentViewControllerFromVC:(UIViewController *)vc {
     while (true) {
         if ([vc isKindOfClass:[UINavigationController class]]) {
             vc = ((UINavigationController *)vc).visibleViewController;
         } else if ([vc isKindOfClass:[UITabBarController class]]) {
             vc = ((UITabBarController *)vc).selectedViewController;
         } else if ([vc isKindOfClass:[UISplitViewController class]]) {
             vc = ((UISplitViewController *)vc).viewControllers.lastObject;
         } else if (vc.presentedViewController) {
                 vc = vc.presentedViewController;
         } else {
             break;
         }
     }
     return vc;
}

+ (UINavigationController *)topNavigationController {
    UIViewController *currentViewController = [self currentViewController];
    UINavigationController *nav = currentViewController.navigationController;

    //因为有像UIAlertController这样的试图控制器，所以需要判断
    if (!nav) {
        nav = (UINavigationController *)((AppDelegate *)([UIApplication sharedApplication].delegate)).window.rootViewController;
    }
    if (!nav) {
        nav = [[UINavigationController alloc] initWithNavigationBarClass:[UINavigationBar class] toolbarClass:nil];
    }
    return nav;
}

@end
