//
//  HorizontalBarChartView.h
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/1/30.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,BarChartType) {
    BarChartTypeSingle = 0,
    BarChartTypeGroup = 1,
    BarChartTypeStack = 2
};

@interface HorizontalBarChartView : UIView
@property (nonatomic, assign) BOOL showYAxisDashLine;
@property (nonatomic, assign) BarChartType chartType;
@end
