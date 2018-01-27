//
//  LineChartView.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/1/26.
//  Copyright © 2018年 杨虎. All rights reserved.
//

static const float TopEdge = 10;
static const float LeftEdge = 50;
static const float RightEdge = 10;
static const float BottomEdge = 20;
static const float minItemWidth = 20;
#define LineChartWidth (self.bounds.size.width-LeftEdge-RightEdge)
#define LineChartHeight (self.bounds.size.height-TopEdge-BottomEdge)

#import "LineChartView.h"
@interface LineChartView()<UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *gestureScroll;
@property (nonatomic, strong) NSMutableArray *xAxisArray;
@property (nonatomic, strong) NSMutableArray *yValueArray;

@property (nonatomic, assign) NSUInteger beginIndex;
@property (nonatomic, assign) NSUInteger endIndex;
@property (nonatomic, assign) CGFloat itemW;
@property (nonatomic, assign) CGFloat itemH;
@property (nonatomic, assign) CGFloat maxYValue;
@property (nonatomic, assign) CGFloat minYValue;

@property (nonatomic, assign) NSUInteger yPostiveSegmentNum;
@property (nonatomic, assign) NSUInteger yNegativeSegmentNum;

@property (nonatomic, assign) CGFloat yItemUnitH;
@property (nonatomic, assign) CGFloat xItemUnitW;
@end

@implementation LineChartView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self addGestureScroll];
    [self findMaxAndMinValue:_beginIndex rightIndex:_endIndex];
    [self calculateYAxisSegment];
    
}

- (void)addGestureScroll {
    if (!_gestureScroll) {
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
        scroll.showsVerticalScrollIndicator = NO;
        scroll.showsHorizontalScrollIndicator = NO;
        scroll.minimumZoomScale = 1.0;
        scroll.maximumZoomScale = 1.0;
        scroll.bounces = NO;
        scroll.delegate = self;
        scroll.backgroundColor = [UIColor blueColor];
        _gestureScroll = scroll;
        [self addSubview:scroll];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)findBeginAndEndIndex {
    CGPoint offset = self.gestureScroll.contentOffset;
    self.beginIndex = floor(offset.x/self.itemW);
    self.endIndex = ceil((offset.x+LineChartWidth)/self.itemW);
    if (self.endIndex > self.yValueArray.count - 1) {
        self.endIndex = self.yValueArray.count - 1;
    }
}

- (void)findMaxAndMinValue:(NSUInteger)leftIndex rightIndex:(NSUInteger)rightIndex {
    if (leftIndex == rightIndex) {
        self.minYValue = MIN([self.yValueArray[leftIndex] floatValue], self.minYValue);
        self.maxYValue = MAX([self.yValueArray[leftIndex] floatValue], self.maxYValue);
        return;
    } else if(leftIndex == rightIndex-1) {
        if ([self.yValueArray[leftIndex] floatValue] < [self.yValueArray[rightIndex] floatValue]) {
            self.minYValue = MIN([self.yValueArray[leftIndex] floatValue], self.minYValue);
            self.maxYValue = MAX([self.yValueArray[rightIndex] floatValue], self.maxYValue);
            return;
        } else {
            self.minYValue = MIN([self.yValueArray[rightIndex] floatValue], self.minYValue);
            self.maxYValue = MAX([self.yValueArray[leftIndex] floatValue], self.maxYValue);
            return;
        }
    }
    NSUInteger mid = (leftIndex + rightIndex)/2;
    [self findMaxAndMinValue:leftIndex rightIndex:mid];
    [self findMaxAndMinValue:mid + 1 rightIndex:rightIndex];
}

- (void)calculateYAxisSegment {
    if (self.minYValue >= 0) {
        self.yPostiveSegmentNum = 4;
        self.yNegativeSegmentNum = 0;
        self.itemH = ceil(self.maxYValue/self.yPostiveSegmentNum);
        self.yItemUnitH = LineChartHeight/(self.itemH * self.yPostiveSegmentNum);
    } else if (self.maxYValue < 0) {
        self.yPostiveSegmentNum = 0;
        self.yNegativeSegmentNum = 4;
        self.itemH = ceil(fabs(self.minYValue)/self.yNegativeSegmentNum);
        self.yItemUnitH = LineChartHeight/(self.itemH * self.yNegativeSegmentNum);
    } else if (self.maxYValue >= fabs(self.minYValue)) {
        self.yPostiveSegmentNum = 4;
        self.itemH = ceil(self.maxYValue/self.yPostiveSegmentNum);
        self.yNegativeSegmentNum = ceil(fabs(self.minYValue)/self.itemH);
        self.yItemUnitH = LineChartHeight/(self.itemH * (self.yPostiveSegmentNum+self.yNegativeSegmentNum));
    } else {
        self.yNegativeSegmentNum = 4;
        self.itemH = ceil(fabs(self.minYValue)/self.yNegativeSegmentNum);
        self.yPostiveSegmentNum = ceil(self.maxYValue/self.itemH);
        self.yItemUnitH = LineChartHeight/(self.itemH * (self.yPostiveSegmentNum+self.yNegativeSegmentNum));
    }
}

- (void)drawYValuePoint {
    CAShapeLayer *yValueLayer = [CAShapeLayer layer];
    UIBezierPath *yValueBezier = [UIBezierPath bezierPath];
    
    for (NSUInteger i=self.beginIndex; i<self.endIndex+1; i++) {
        CGFloat yPoint = [self.yValueArray[i] floatValue] * _yItemUnitH;
        CGPoint p = CGPointMake((i+1)*self.itemW, yPoint);
        if (i == self.beginIndex) {
            [yValueBezier moveToPoint:p];
        } else {
            [yValueBezier addLineToPoint:p];
        }
    }
    yValueLayer.path = yValueBezier.CGPath;
    yValueLayer.backgroundColor = [UIColor blueColor].CGColor;
    yValueLayer.lineWidth = 0.5;
    
}
- (void)redraw {
    
}

- (NSMutableArray *)xAxisArray {
    if (!_xAxisArray) {
        _xAxisArray = [NSMutableArray arrayWithObjects:@"Mon",@"",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun", nil];
    }
    return _xAxisArray;
}
- (NSMutableArray *)yValueArray {
    if (!_yValueArray) {
        _yValueArray = [NSMutableArray arrayWithObjects:@50,@20,@70,@30,@11,@59,@199, nil];
    }
    return _yValueArray;
}
- (CGFloat)itemW {
    if (_itemW == 0) {
        _itemW = LineChartWidth/self.yValueArray.count > minItemWidth ? (LineChartWidth/self.yValueArray.count) : minItemWidth;
    }
    return _itemW;
}
@end
