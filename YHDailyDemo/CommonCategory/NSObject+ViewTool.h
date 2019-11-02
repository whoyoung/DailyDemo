//
//  NSObject+ViewTool.h
//  YHDailyDemo
//
//  Created by young on 2019/11/2.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ViewTool)

+ (UIViewController *)currentViewController;

+ (UIViewController *)currentViewControllerFromVC:(UIViewController *)vc;

+ (UINavigationController *)topNavigationController;

@end

NS_ASSUME_NONNULL_END
