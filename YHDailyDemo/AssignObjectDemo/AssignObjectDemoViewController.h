//
//  AssignObjectDemoViewController.h
//  YHDailyDemo
//
//  Created by young on 2018/3/25.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestObject : UIViewController
@property (nonatomic, assign) NSUInteger num;
@end

@interface AssignObjectDemoViewController : UIViewController
@property (nonatomic, assign) TestObject *obj;
@end
