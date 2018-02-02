//
//  HorizontalBarChartView.h
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/1/30.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonChartViewDelegate.h"

@interface HorizontalBarChartView : UIView
@property (nonatomic, weak) id<CommonChartViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame configure:(NSDictionary *)configureDict;
@end


