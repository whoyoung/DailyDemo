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

- (id)initWithFrame:(CGRect)frame configure:(NSDictionary *)configureDict;

- (void)dealStyleDict:(NSDictionary *)styleDict;
- (void)chartDidZooming:(UIPinchGestureRecognizer *)pinGesture;
- (void)chartDidTapping:(UITapGestureRecognizer *)tapGesture;
- (NSDictionary *)tappedGroupAndItem:(CGPoint)tapP;
- (NSDictionary *)prepareTipViewData:(NSUInteger)group item:(NSUInteger)item containerPoint:(CGPoint)point;
- (CGSize)gestureScrollContentSize;

- (void)findBeginAndEndIndex;
- (void)calculateMaxAndMinValue;
- (void)calculateDataSegment;
- (void)addAxisLayer;
- (void)addAxisScaleLayer;
- (void)addDataLayer;
- (void)addDataScaleLayer;
- (void)drawDataPoint;
@end
