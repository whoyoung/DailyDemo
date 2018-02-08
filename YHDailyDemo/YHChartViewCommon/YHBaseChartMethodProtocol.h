//
//  YHBaseChartMethodProtocol.h
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/2/8.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YHBaseChartMethodProtocol <NSObject>
@required
- (id)initWithFrame:(CGRect)frame configure:(NSDictionary *)configureDict;

- (void)dealStyleDict:(NSDictionary *)styleDict;
- (CGSize)gestureScrollContentSize;
- (void)chartDidZooming:(UIPinchGestureRecognizer *)pinGesture;
- (NSDictionary *)tappedGroupAndItem:(CGPoint)tapP;
- (NSDictionary *)prepareTipViewData:(NSUInteger)group item:(NSUInteger)item containerPoint:(CGPoint)point;

- (void)findGroupAndItemIndex;
- (void)calculateMaxAndMinValue;
- (CGFloat)dataItemUnitScale;
- (void)addAxisLayer;
- (void)addAxisScaleLayer;
- (void)addDataLayer;
- (void)addDataScaleLayer;
- (void)drawDataPoint;
@end
