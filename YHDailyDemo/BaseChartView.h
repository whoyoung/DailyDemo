//
//  BaseChartView.h
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/2/2.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonChartViewDelegate.h"

@interface BaseChartView : UIView
@property (nonatomic, weak) id<CommonChartViewDelegate> delegate;

@property (nonatomic, assign) CGFloat scrollContentSizeWidth;

- (id)initWithFrame:(CGRect)frame configure:(NSDictionary *)configureDict;
@end
