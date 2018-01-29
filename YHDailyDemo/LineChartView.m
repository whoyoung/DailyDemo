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
static const float XTextHeight = 15;
static const float YTextWidth = 45;

#define LineChartWidth (self.bounds.size.width-LeftEdge-RightEdge)
#define LineChartHeight (self.bounds.size.height-TopEdge-BottomEdge)

#import "LineChartView.h"
@interface LineChartView()<UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *gestureScroll;
@property (nonatomic, strong) NSMutableArray *xAxisArray;

@property (nonatomic, assign) NSInteger beginIndex;
@property (nonatomic, assign) NSInteger endIndex;
@property (nonatomic, assign) CGFloat itemW;
@property (nonatomic, assign) CGFloat itemH;
@property (nonatomic, assign) CGFloat maxYValue;
@property (nonatomic, assign) CGFloat minYValue;

@property (nonatomic, assign) NSUInteger yPostiveSegmentNum;
@property (nonatomic, assign) NSUInteger yNegativeSegmentNum;

@property (nonatomic, assign) CGFloat yItemUnitH;
@property (nonatomic, assign) CGFloat xItemUnitW;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, assign) CGFloat oldPinScale;
@property (nonatomic, assign) CGFloat newPinScale;
@property (nonatomic, assign) CGFloat pinCenterToLeftDistance;
@property (nonatomic, assign) CGFloat pinCenterRatio;
@property (nonatomic, assign) CGFloat zoomedItemW;
@property (nonatomic, strong) NSArray *yValues;
@property (nonatomic, strong) NSArray *lineColors;
@end

@implementation LineChartView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addGestureScroll];
    self.gestureScroll.contentSize = CGSizeMake([self.yValues[0] count]*self.zoomedItemW, LineChartHeight);
    if (!_containerView) {
        [self redraw];
    }
}

- (void)addGestureScroll {
    if (!_gestureScroll) {
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(LeftEdge, TopEdge, LineChartWidth, LineChartHeight)];
        scroll.showsVerticalScrollIndicator = NO;
        scroll.showsHorizontalScrollIndicator = NO;
        scroll.minimumZoomScale = 1.0;
        scroll.maximumZoomScale = 1.0;
        scroll.bounces = NO;
        scroll.delegate = self;
        scroll.backgroundColor = [UIColor clearColor];
        _gestureScroll = scroll;
        [self addSubview:scroll];
        
        UIPinchGestureRecognizer *pinGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(chartDidZooming:)];
        [_gestureScroll addGestureRecognizer:pinGesture];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self redraw];
}
- (void)chartDidZooming:(UIPinchGestureRecognizer *)pinGesture {
    switch (pinGesture.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint pinCenterContainer = [pinGesture locationInView:self.containerView];
            _pinCenterToLeftDistance = pinCenterContainer.x - LeftEdge;
            CGPoint pinCenterScrollView = [pinGesture locationInView:self.containerView];
            _pinCenterRatio = pinCenterScrollView.x/self.gestureScroll.contentSize.width;
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (pinGesture.scale < 1 && [self.yValues[0] count]*self.zoomedItemW <= LineChartWidth) {
                _newPinScale = LineChartWidth/([self.yValues[0] count]*self.itemW*_oldPinScale);
            } else {
                _newPinScale = pinGesture.scale;
            }
            [self adjustScroll];
            [self redraw];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            _oldPinScale *= _newPinScale;
        }
            break;
            
        default:
            break;
    }
}
- (void)adjustScroll {
    self.gestureScroll.contentSize = CGSizeMake([self.yValues[0] count]*self.zoomedItemW, LineChartHeight);
    CGFloat offsetX = self.gestureScroll.contentSize.width * self.pinCenterRatio - self.pinCenterToLeftDistance;
    if (offsetX < 0) {
        offsetX = 0;
    }
    if (self.gestureScroll.contentSize.width > LineChartWidth) {
        if (offsetX > self.gestureScroll.contentSize.width - LineChartWidth) {
            offsetX = self.gestureScroll.contentSize.width - LineChartWidth;
        }
    } else {
        offsetX = 0;
    }
    self.gestureScroll.contentOffset = CGPointMake(offsetX, 0);
}
- (void)redraw {
    [_containerView removeFromSuperview];
    _containerView = nil;
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    _containerView.backgroundColor = [UIColor whiteColor];
    
    [self insertSubview:_containerView belowSubview:_gestureScroll];
    [self findBeginAndEndIndex];
    self.minYValue = [self.yValues[0][_beginIndex] floatValue];
    self.maxYValue = self.minYValue;
    [self campareMaxAndMinValue:_beginIndex rightIndex:_endIndex];
    [self calculateYAxisSegment];
    [self drawYValuePoint];
    [self addXAxisLayer];
    [self addXScaleLayer];
    [self addYAxisLayer];
    [self addYScaleLayer];
}

- (void)findBeginAndEndIndex {
    CGPoint offset = self.gestureScroll.contentOffset;
    self.beginIndex = floor(offset.x/self.zoomedItemW);
    self.endIndex = ceil((offset.x+LineChartWidth)/self.zoomedItemW);
    if (self.beginIndex < 0) {
        self.beginIndex = 0;
    }
    if (self.endIndex > [self.yValues[0] count] - 1) {
        self.endIndex = [self.yValues[0] count] - 1;
    }
    if (self.beginIndex > self.endIndex) {
        self.beginIndex = self.endIndex;
    }
}

- (void)campareMaxAndMinValue:(NSUInteger)leftIndex rightIndex:(NSUInteger)rightIndex {
    for (NSArray *values in self.yValues) {
        [self findMaxAndMinValue:leftIndex rightIndex:rightIndex compareA:values];
    }
}
- (void)findMaxAndMinValue:(NSUInteger)leftIndex rightIndex:(NSUInteger)rightIndex compareA:(NSArray *)compareA {
    if (leftIndex > rightIndex) {
        leftIndex = rightIndex;
    }
    if (leftIndex == rightIndex) {
        self.minYValue = MIN([compareA[leftIndex] floatValue], self.minYValue);
        self.maxYValue = MAX([compareA[leftIndex] floatValue], self.maxYValue);
        return;
    } else if(leftIndex == rightIndex-1) {
        if ([compareA[leftIndex] floatValue] < [compareA[rightIndex] floatValue]) {
            self.minYValue = MIN([compareA[leftIndex] floatValue], self.minYValue);
            self.maxYValue = MAX([compareA[rightIndex] floatValue], self.maxYValue);
            return;
        } else {
            self.minYValue = MIN([compareA[rightIndex] floatValue], self.minYValue);
            self.maxYValue = MAX([compareA[leftIndex] floatValue], self.maxYValue);
            return;
        }
    }
    NSUInteger mid = (leftIndex + rightIndex)/2;
    [self findMaxAndMinValue:leftIndex rightIndex:mid compareA:compareA];
    [self findMaxAndMinValue:mid + 1 rightIndex:rightIndex compareA:compareA];
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
    for (NSUInteger i=0;i<self.yValues.count;i++) {
        NSArray *values = self.yValues[i];
        CAShapeLayer *yValueLayer = [CAShapeLayer layer];
        UIBezierPath *yValueBezier = [UIBezierPath bezierPath];
        CGFloat offsetX = self.gestureScroll.contentOffset.x;
        CGFloat zeroY = TopEdge + _yPostiveSegmentNum * self.yAxisUnitH;
        for (NSUInteger i=self.beginIndex; i<self.endIndex+1; i++) {
            CGFloat yPoint = zeroY - [values[i] floatValue] * _yItemUnitH;
            CGPoint p = CGPointMake((i+1)*self.zoomedItemW-offsetX+LeftEdge, yPoint);
            if (i == self.beginIndex) {
                [yValueBezier moveToPoint:p];
            } else {
                [yValueBezier addLineToPoint:p];
            }
        }
        yValueLayer.path = yValueBezier.CGPath;
        yValueLayer.lineWidth = 1;
        yValueLayer.strokeColor = [self.lineColors[i] CGColor];
        yValueLayer.fillColor = [UIColor clearColor].CGColor;
        [self.containerView.layer addSublayer:yValueLayer];
    }
    
}

- (void)addXAxisLayer {
    CGFloat offsetX = self.gestureScroll.contentOffset.x;
    for (NSUInteger i=_beginIndex; i<=_endIndex; i++) {
        CGRect textFrame = CGRectMake(LeftEdge+self.zoomedItemW/2.0 + self.zoomedItemW*i - offsetX, self.bounds.size.height-XTextHeight, self.zoomedItemW, XTextHeight);
        CATextLayer *text = [self getTextLayerWithString:self.xAxisArray[i] textColor:[UIColor blackColor] fontSize:12 backgroundColor:[UIColor clearColor] frame:textFrame];
        [self.containerView.layer addSublayer:text];
    }
}
- (void)addXScaleLayer {
    CAShapeLayer *xScaleLayer = [CAShapeLayer layer];
    UIBezierPath *xScaleBezier = [UIBezierPath bezierPath];
    [xScaleBezier moveToPoint:CGPointMake(LeftEdge, self.bounds.size.height-BottomEdge)];
    [xScaleBezier addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height-BottomEdge)];
    
    CGFloat offsetX = self.gestureScroll.contentOffset.x;
    for (NSUInteger i=_beginIndex; i<=_endIndex; i++) {
        [xScaleBezier moveToPoint:CGPointMake(LeftEdge + self.zoomedItemW*(i+1) - offsetX, self.bounds.size.height-BottomEdge-1)];
        [xScaleBezier addLineToPoint:CGPointMake(LeftEdge + self.zoomedItemW*(i+1) - offsetX, self.bounds.size.height-BottomEdge+5)];
    }
    xScaleLayer.path = xScaleBezier.CGPath;
    xScaleLayer.lineWidth = 1;
    xScaleLayer.strokeColor = [UIColor blackColor].CGColor;
    xScaleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.containerView.layer addSublayer:xScaleLayer];
    
    if (_showXAxisDashLine) {
        CAShapeLayer *dashLineLayer = [CAShapeLayer layer];
        UIBezierPath *dashLineBezier = [UIBezierPath bezierPath];
        for (NSUInteger i=_beginIndex; i<=_endIndex; i++) {
            [dashLineBezier moveToPoint:CGPointMake(LeftEdge + self.zoomedItemW*(i+1) - offsetX, self.bounds.size.height-BottomEdge-1)];
            [dashLineBezier addLineToPoint:CGPointMake(LeftEdge + self.zoomedItemW*(i+1) - offsetX, TopEdge)];
        }
        dashLineLayer.path = dashLineBezier.CGPath;
        [dashLineLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:5], nil]];
        dashLineLayer.lineWidth = 1;
        dashLineLayer.strokeColor = [UIColor blackColor].CGColor;
        dashLineLayer.fillColor = [UIColor clearColor].CGColor;
        [self.containerView.layer addSublayer:dashLineLayer];
    }
}
- (void)addYAxisLayer {
    for (NSUInteger i=0; i<_yNegativeSegmentNum; i++) {
        CGRect textFrame = CGRectMake(0, self.bounds.size.height-1.5*BottomEdge-i*self.yAxisUnitH, YTextWidth, BottomEdge);
        CATextLayer *text = [self getTextLayerWithString:[NSString stringWithFormat:@"-%.2f",(_yNegativeSegmentNum-i)*_itemH] textColor:[UIColor blackColor] fontSize:12 backgroundColor:[UIColor clearColor] frame:textFrame];
        [self.containerView.layer addSublayer:text];
    }
    for (NSInteger i=0; i<=_yPostiveSegmentNum+1; i++) {
        CGRect textFrame = CGRectMake(0, self.bounds.size.height-1.5*BottomEdge-(_yNegativeSegmentNum+i)*self.yAxisUnitH, YTextWidth, BottomEdge);
        CATextLayer *text = [self getTextLayerWithString:[NSString stringWithFormat:@"%.2f",i*_itemH] textColor:[UIColor blackColor] fontSize:12 backgroundColor:[UIColor clearColor] frame:textFrame];
        [self.containerView.layer addSublayer:text];
    }
}
- (void)addYScaleLayer {
    CAShapeLayer *yScaleLayer = [CAShapeLayer layer];
    UIBezierPath *yScaleBezier = [UIBezierPath bezierPath];
    [yScaleBezier moveToPoint:CGPointMake(LeftEdge+1, TopEdge)];
    [yScaleBezier addLineToPoint:CGPointMake(LeftEdge+1, self.bounds.size.height-BottomEdge)];
    
    for (NSUInteger i=0; i<=_yNegativeSegmentNum+_yPostiveSegmentNum+1; i++) {
        [yScaleBezier moveToPoint:CGPointMake(LeftEdge-5, TopEdge+i*self.yAxisUnitH)];
        [yScaleBezier addLineToPoint:CGPointMake(LeftEdge+1, TopEdge+i*self.yAxisUnitH)];
    }
    yScaleLayer.path = yScaleBezier.CGPath;
    yScaleLayer.backgroundColor = [UIColor blueColor].CGColor;
    yScaleLayer.lineWidth = 1;
    yScaleLayer.strokeColor = [UIColor blackColor].CGColor;
    yScaleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.containerView.layer addSublayer:yScaleLayer];
    
    if (_showYAxisDashLine) {
        CAShapeLayer *dashLineLayer = [CAShapeLayer layer];
        UIBezierPath *dashLineBezier = [UIBezierPath bezierPath];
        for (NSUInteger i=0; i<=_yNegativeSegmentNum+_yPostiveSegmentNum; i++) {
            [dashLineBezier moveToPoint:CGPointMake(LeftEdge+1, TopEdge+i*self.yAxisUnitH)];
            [dashLineBezier addLineToPoint:CGPointMake(self.bounds.size.width, TopEdge+i*self.yAxisUnitH)];
        }
        dashLineLayer.path = dashLineBezier.CGPath;
        [dashLineLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:5], nil]];
        dashLineLayer.lineWidth = 1;
        dashLineLayer.strokeColor = [UIColor blackColor].CGColor;
        dashLineLayer.fillColor = [UIColor clearColor].CGColor;
        [self.containerView.layer addSublayer:dashLineLayer];
    }
}
- (CATextLayer *)getTextLayerWithString:(NSString *)text
                              textColor:(UIColor *)textColor
                               fontSize:(NSInteger)fontSize
                        backgroundColor:(UIColor *)bgColor
                                  frame:(CGRect)frame {
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.frame = frame;
    textLayer.string = text;
    textLayer.fontSize = fontSize;
    textLayer.foregroundColor = textColor.CGColor;
    textLayer.backgroundColor = bgColor.CGColor;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.wrapped = YES;
    //设置分辨率
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    return textLayer;
}

- (NSMutableArray *)xAxisArray {
    if (!_xAxisArray) {
        _xAxisArray = [NSMutableArray arrayWithObjects:@"Mon",@"Tues",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun",@"Mon",@"Tues",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun",@"Mon",@"Tues",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun",@"Mon",@"Tues",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun",@"Mon",@"Tues",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun",@"Mon",@"Tues",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun",@"Mon",@"Tues",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun",@"Mon",@"Tues",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun", nil];
    }
    return _xAxisArray;
}

- (NSArray *)yValues {
    if (!_yValues) {
        _yValues = @[
  @[@50,@20,@70,@30,@-11,@59,@399,@50,@20,@70,@30,@11,@59,@299,@50,@20,@70,@30,@11,@59,@199,@50,@20,@70,@30,@11,@59,@-99,@50,@20,@70,@30,@11,@59,@399,@50,@20,@70,@30,@11,@59,@299,@50,@20,@70,@30,@11,@59,@199,@50,@20,@70,@30,@11,@59,@99],
  @[@144,@50,@25,@170,@50,@20,@80,@99,@50,@20,@70,@30,@11,@59,@30,@20,@70,@30,@11,@59,@39,@50,@20,@70,@30,@11,@59,@-9,@30,@11,@59,@219,@50,@20,@70,@30,@11,@59,@19,@50,@20,@11,@49,@99,@50,@70,@30,@11,@59,@29,@-50,@20,@70,@40,@11,@59],
  @[@33,@80,@110,@44,@20,@177,@150,@80,@250,@10,@69,@110,@90,@-569,@3,@220,@75,@399,@122,@59,@39,@50,@29,@170,@30,@11,@59,@9,@30,@11,@59,@219,@50,@550,@70,@30,@141,@59,@69,@50,@30,@11,@19,@93,@20,@550,@50,@71,@569,@29,@20,@10,@70,@410,@101,@589]
                     ];
    }
    return _yValues;
}
- (CGFloat)itemW {
    if (_itemW == 0) {
        _itemW = LineChartWidth/[self.yValues[0] count] > minItemWidth ? (LineChartWidth/[self.yValues[0] count]) : minItemWidth;
    }
    return _itemW;
}
- (CGFloat)zoomedItemW {
    return self.itemW * self.newPinScale * self.oldPinScale;
}
- (CGFloat)yAxisUnitH {
    return LineChartHeight/(_yNegativeSegmentNum + _yPostiveSegmentNum);
}
- (CGFloat)oldPinScale {
    if (_oldPinScale == 0) {
        _oldPinScale = 1.0;
    }
    return _oldPinScale;
}
- (CGFloat)newPinScale {
    if (_newPinScale == 0) {
        _newPinScale = 1.0;
    }
    return _newPinScale;
}
- (NSArray *)lineColors {
    if (!_lineColors) {
        NSMutableArray *colors = [NSMutableArray arrayWithCapacity:self.yValues.count];
        for (NSUInteger i=0; i<self.yValues.count; i++) {
            UIColor *color = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1];
            [colors addObject:color];
        }
        _lineColors = [colors copy];
    }
    return _lineColors;
}
@end
