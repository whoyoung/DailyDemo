//
//  BaseChartView.h
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/2/2.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonChartViewDelegate.h"
#import "CommonHeader.h"

typedef NS_ENUM(NSUInteger,BarChartType) {
    BarChartTypeSingle = 0,
    BarChartTypeGroup = 1,
    BarChartTypeStack = 2
};

@interface BaseChartView : UIView 

@property (nonatomic, weak) id<CommonChartViewDelegate> delegate;
@property (nonatomic, weak, readonly) UIScrollView *gestureScroll;
@property (nonatomic, strong, readonly) UIView *containerView;

@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *AxisArray;
@property (nonatomic, strong, readonly) NSArray<NSArray *> *Datas;
@property (nonatomic, strong, readonly) NSArray *groupMembers;
@property (nonatomic, copy, readonly) NSString *axisTitle;
@property (nonatomic, copy, readonly) NSString *dataTitle;
@property (nonatomic, strong, readonly) NSArray *itemColors;
@property (nonatomic, assign, readonly) BarChartType chartType;
@property (nonatomic, assign, readonly) NSUInteger valueInterval;

@property (nonatomic, assign, readonly) NSUInteger dataPostiveSegmentNum;
@property (nonatomic, assign, readonly) NSUInteger dataNegativeSegmentNum;
@property (nonatomic, assign, readonly) CGFloat dataItemUnitScale;
@property (nonatomic, assign, readonly) CGFloat zoomedItemAxis;
@property (nonatomic, assign, readonly) BOOL isDataError;
@property (nonatomic, assign, readonly) CGFloat zeroLine;

@property (nonatomic, assign) CGFloat minItemWidth;
@property (nonatomic, assign) CGFloat groupSpace;
@property (nonatomic, assign) BOOL showDataDashLine;
@property (nonatomic, assign) BOOL showDataHardLine;
@property (nonatomic, assign) BOOL showAxisDashLine;
@property (nonatomic, assign) BOOL showAxisHardLine;
@property (nonatomic, assign) BOOL showDataEdgeLine;

@property (nonatomic, assign) NSInteger beginGroupIndex;
@property (nonatomic, assign) NSInteger endGroupIndex;
@property (nonatomic, assign) NSInteger beginItemIndex;
@property (nonatomic, assign) NSInteger endItemIndex;
@property (nonatomic, assign) CGFloat itemAxisScale;
@property (nonatomic, assign) NSUInteger itemDataScale;
@property (nonatomic, assign) CGFloat maxDataValue;
@property (nonatomic, assign) CGFloat minDataValue;

@property (nonatomic, assign) CGFloat oldPinScale;
@property (nonatomic, assign) CGFloat newPinScale;
@property (nonatomic, assign) CGFloat pinCenterToLeftDistance;
@property (nonatomic, assign) CGFloat pinCenterRatio;

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

- (void)redraw;
- (void)compareBeginAndEndItemValue:(NSUInteger)beginItem endItem:(NSUInteger)endItem isBeginGroup:(BOOL)isBeginGroup;
- (void)campareMaxAndMinValue:(NSUInteger)leftIndex rightIndex:(NSUInteger)rightIndex;
- (void)findMaxAndMinValue:(NSUInteger)leftIndex rightIndex:(NSUInteger)rightIndex compareA:(NSArray *)compareA;
- (NSString *)adjustScaleValue:(NSUInteger)scaleValue;
- (CATextLayer *)getTextLayerWithString:(NSString *)text
                              textColor:(UIColor *)textColor
                               fontSize:(NSInteger)fontSize
                        backgroundColor:(UIColor *)bgColor
                                  frame:(CGRect)frame
                          alignmentMode:(NSString *)alignmentMode;
- (CGFloat)zoomedItemAxis;
@end
