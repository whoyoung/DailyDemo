//
//  NestedBlockDemoViewController.h
//  YHDailyDemo
//
//  Created by young on 2018/3/31.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^BlockA)(NSString *);
typedef void (^BlockB)(NSString *,BlockA);
typedef void (^BlockC)(void);

@interface NestedBlockDemoViewController : UIViewController
@property (nonatomic, copy) BlockA blockA;
@property (nonatomic, copy) BlockB blockB;
@end
