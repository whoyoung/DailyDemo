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
static const float TextHeight = 11;
static const float TextWidth = 45;
static const float AxistTextFont = 9;
static const float DataTextFont = 8;
static const float TipTextFont = 9;

#define ChartWidth (self.bounds.size.width-LeftEdge-RightEdge)
#define ChartHeight (self.bounds.size.height-TopEdge-BottomEdge)
#define AxisTextColor [UIColor hexChangeFloat:@"8899A6"]
#define AxisScaleColor [UIColor hexChangeFloat:@"EEEEEE"]
#define DataTextColor [UIColor hexChangeFloat:@"8FA1B2"]
#define TipTextColor [UIColor whiteColor]

#import "LineChartView.h"
#import "UIColor+HexColor.h"
@interface LineChartView()<UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *gestureScroll;
@property (nonatomic, strong) NSMutableArray<NSString *> *AxisArray;
@property (nonatomic, strong) NSArray<NSArray *> *Datas;

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

@property (nonatomic, assign) BOOL isDataError;
@property (nonatomic, strong) NSArray *groupMembers;
@property (nonatomic, copy) NSString *axisTitle;
@property (nonatomic, copy) NSString *dataTitle;
@property (nonatomic, strong) NSArray *itemColors;
@property (nonatomic, assign) NSUInteger valueInterval;
@property (nonatomic, assign) CGFloat zeroLine;
@property (nonatomic, assign) BOOL showDataDashLine;
@property (nonatomic, assign) BOOL hideDataHardLine;
@property (nonatomic, assign) CGFloat minItemWidth;

@end

@implementation LineChartView

- (id)initWithFrame:(CGRect)frame configure:(NSDictionary *)configureDict {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self dealChartConfigure:configureDict];
        self.layer.masksToBounds = YES;
    }
    return self;
}
- (void)dealChartConfigure:(NSDictionary *)dict {
    self.AxisArray = [dict objectForKey:@"axis"];
    self.Datas = [dict objectForKey:@"datas"];
    self.isDataError = !self.AxisArray || ![self.AxisArray isKindOfClass:[NSArray class]] || !self.AxisArray.count || !self.Datas || ![self.Datas isKindOfClass:[NSArray class]] || !self.Datas.count;
    
    self.groupMembers = [dict objectForKey:@"groupMembers"];
    self.axisTitle = [dict objectForKey:@"axisTitle"];
    self.dataTitle = [dict objectForKey:@"dataTitle"];
    self.itemColors = [dict objectForKey:@"colors"];
    if (!self.itemColors) {
        [self defaultColors];
    }
    self.valueInterval = [[dict objectForKey:@"valueInterval"] integerValue];
    if (self.valueInterval == 0) {
        self.valueInterval = 3;
    }
    NSDictionary *styleDict = [dict objectForKey:@"styles"];
    NSDictionary *lineStyle = [styleDict objectForKey:@"lineStyle"];
    self.minItemWidth = [lineStyle objectForKey:@"minItemWidth"] ? [[lineStyle objectForKey:@"minItemWidth"] floatValue] : 20;

}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isDataError) {
        CGRect textFrame = CGRectMake(0,( ChartHeight-TextHeight)/2.0, ChartWidth, TextHeight);
        CATextLayer *text = [self getTextLayerWithString:@"数据格式有误" textColor:[UIColor lightGrayColor] fontSize:14 backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentCenter];
        [self.layer addSublayer:text];
        return;
    }
    [self addGestureScroll];
    self.gestureScroll.contentSize = CGSizeMake([self.Datas[0] count]*self.zoomedItemW, ChartHeight);
    if (!_containerView) {
        [self redraw];
    }
}

- (void)addGestureScroll {
    if (!_gestureScroll) {
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(LeftEdge, TopEdge, ChartWidth, ChartHeight)];
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
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chartDidTapping:)];
        tapGesture.numberOfTapsRequired = 1;
        [_gestureScroll addGestureRecognizer:tapGesture];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.newPinScale = 1.0;
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
            if (pinGesture.scale < 1 && [self.Datas[0] count]*self.itemW*_oldPinScale*pinGesture.scale <= ChartWidth) {
                _newPinScale = ChartWidth/([self.Datas[0] count]*self.itemW*_oldPinScale);
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
    self.gestureScroll.contentSize = CGSizeMake([self.Datas[0] count]*self.zoomedItemW, ChartHeight);
    CGFloat offsetX = self.gestureScroll.contentSize.width * self.pinCenterRatio - self.pinCenterToLeftDistance;
    if (offsetX < 0) {
        offsetX = 0;
    }
    if (self.gestureScroll.contentSize.width > ChartWidth) {
        if (offsetX > self.gestureScroll.contentSize.width - ChartWidth) {
            offsetX = self.gestureScroll.contentSize.width - ChartWidth;
        }
    } else {
        offsetX = 0;
    }
    self.gestureScroll.contentOffset = CGPointMake(offsetX, 0);
}
- (void)chartDidTapping:(UITapGestureRecognizer *)tapGesture {
    [self removeTipView];
    CGPoint tapP = [tapGesture locationInView:self.gestureScroll];
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(tapP.x, tapP.y, 50, 50)];
    tipView.backgroundColor = [UIColor  redColor];
    tipView.tag = 101;
    [self.gestureScroll addSubview:tipView];
}
- (void)removeTipView {
    UIView *existedV = [self.gestureScroll viewWithTag:101];
    [existedV removeFromSuperview];
}
- (void)redraw {
    [_containerView removeFromSuperview];
    _containerView = nil;
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    _containerView.backgroundColor = [UIColor whiteColor];
    
    [self insertSubview:_containerView belowSubview:_gestureScroll];
    [self findBeginAndEndIndex];
    self.minYValue = [self.Datas[0][_beginIndex] floatValue];
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
    self.endIndex = ceil((offset.x+ChartWidth)/self.zoomedItemW);
    if (self.beginIndex < 0) {
        self.beginIndex = 0;
    }
    if (self.endIndex > [self.Datas[0] count] - 1) {
        self.endIndex = [self.Datas[0] count] - 1;
    }
    if (self.beginIndex > self.endIndex) {
        self.beginIndex = self.endIndex;
    }
}

- (void)campareMaxAndMinValue:(NSUInteger)leftIndex rightIndex:(NSUInteger)rightIndex {
    for (NSArray *values in self.Datas) {
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
        if(self.maxYValue < 1) self.yPostiveSegmentNum = 1;
        self.yNegativeSegmentNum = 0;
        self.itemH = ceil(self.maxYValue/self.yPostiveSegmentNum);
        self.yItemUnitH = ChartHeight/(self.itemH * self.yPostiveSegmentNum);
    } else if (self.maxYValue < 0) {
        self.yPostiveSegmentNum = 0;
        self.yNegativeSegmentNum = 4;
        if(fabs(self.minYValue) < 1) self.yNegativeSegmentNum = 1;
        self.itemH = ceil(fabs(self.minYValue)/self.yNegativeSegmentNum);
        self.yItemUnitH = ChartHeight/(self.itemH * self.yNegativeSegmentNum);
    } else if (self.maxYValue >= fabs(self.minYValue)) {
        self.yPostiveSegmentNum = 4;
        if(self.maxYValue < 1) self.yPostiveSegmentNum = 1;
        self.itemH = ceil(self.maxYValue/self.yPostiveSegmentNum);
        self.yNegativeSegmentNum = ceil(fabs(self.minYValue)/self.itemH);
        self.yItemUnitH = ChartHeight/(self.itemH * (self.yPostiveSegmentNum+self.yNegativeSegmentNum));
    } else {
        self.yNegativeSegmentNum = 4;
        if(fabs(self.minYValue) < 1) self.yNegativeSegmentNum = 1;
        self.itemH = ceil(fabs(self.minYValue)/self.yNegativeSegmentNum);
        self.yPostiveSegmentNum = ceil(self.maxYValue/self.itemH);
        self.yItemUnitH = ChartHeight/(self.itemH * (self.yPostiveSegmentNum+self.yNegativeSegmentNum));
    }
}

- (void)drawYValuePoint {
    UIView *subContainerV = [[UIView alloc] initWithFrame:CGRectMake(LeftEdge, TopEdge, ChartWidth, ChartHeight)];
    subContainerV.layer.masksToBounds = YES;
    [self.containerView addSubview:subContainerV];
    for (NSUInteger i=0;i<self.Datas.count;i++) {
        NSArray *values = self.Datas[i];
        CAShapeLayer *yValueLayer = [CAShapeLayer layer];
        UIBezierPath *yValueBezier = [UIBezierPath bezierPath];
        CGFloat offsetX = self.gestureScroll.contentOffset.x;
        CGFloat zeroY = _yPostiveSegmentNum * self.yAxisUnitH;
        for (NSUInteger i=self.beginIndex; i<self.endIndex+1; i++) {
            CGFloat yPoint = zeroY - [values[i] floatValue] * _yItemUnitH;
            CGPoint p = CGPointMake(i*self.zoomedItemW-offsetX, yPoint);
            if (i == self.beginIndex) {
                [yValueBezier moveToPoint:p];
            } else {
                [yValueBezier addLineToPoint:p];
            }
        }
        yValueLayer.path = yValueBezier.CGPath;
        yValueLayer.lineWidth = 1;
        yValueLayer.strokeColor = [[UIColor hexChangeFloat:self.itemColors[i]] CGColor];
        yValueLayer.fillColor = [UIColor clearColor].CGColor;
        [subContainerV.layer addSublayer:yValueLayer];
    }
    
}

- (void)addXAxisLayer {
    CGFloat offsetX = self.gestureScroll.contentOffset.x;
    for (NSUInteger i=_beginIndex; i<=_endIndex; i++) {
        if (self.zoomedItemW*i-offsetX < 0) continue;
        CGRect textFrame = CGRectMake(LeftEdge + self.zoomedItemW*i-offsetX-self.zoomedItemW/2.0, self.bounds.size.height-TextHeight, self.zoomedItemW, TextHeight);
        CATextLayer *text = [self getTextLayerWithString:self.AxisArray[i] textColor:[UIColor blackColor] fontSize:12 backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentCenter];
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
        if (self.zoomedItemW*i - offsetX < 0) continue;
        [xScaleBezier moveToPoint:CGPointMake(LeftEdge + self.zoomedItemW*i - offsetX, self.bounds.size.height-BottomEdge)];
        [xScaleBezier addLineToPoint:CGPointMake(LeftEdge + self.zoomedItemW*i - offsetX, self.bounds.size.height-BottomEdge+5)];
    }
    xScaleLayer.path = xScaleBezier.CGPath;
    xScaleLayer.lineWidth = 1;
    xScaleLayer.strokeColor = [UIColor blackColor].CGColor;
    xScaleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.containerView.layer addSublayer:xScaleLayer];
    
    if (_showDataDashLine) {
        CAShapeLayer *dashLineLayer = [CAShapeLayer layer];
        UIBezierPath *dashLineBezier = [UIBezierPath bezierPath];
        for (NSUInteger i=_beginIndex; i<=_endIndex; i++) {
            if (self.zoomedItemW*i - offsetX < 0) continue;
            [dashLineBezier moveToPoint:CGPointMake(LeftEdge + self.zoomedItemW*i - offsetX, self.bounds.size.height-BottomEdge-1)];
            [dashLineBezier addLineToPoint:CGPointMake(LeftEdge + self.zoomedItemW*i - offsetX, TopEdge)];
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
        CGRect textFrame = CGRectMake(0, self.bounds.size.height-1.5*BottomEdge-i*self.yAxisUnitH, TextWidth, BottomEdge);
        CATextLayer *text = [self getTextLayerWithString:[NSString stringWithFormat:@"-%.2f",(_yNegativeSegmentNum-i)*_itemH] textColor:[UIColor blackColor] fontSize:12 backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentRight];
        [self.containerView.layer addSublayer:text];
    }
    for (NSInteger i=0; i<=_yPostiveSegmentNum+1; i++) {
        CGRect textFrame = CGRectMake(0, self.bounds.size.height-1.5*BottomEdge-(_yNegativeSegmentNum+i)*self.yAxisUnitH, TextWidth, BottomEdge);
        CATextLayer *text = [self getTextLayerWithString:[NSString stringWithFormat:@"%.2f",i*_itemH] textColor:[UIColor blackColor] fontSize:12 backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentRight];
        [self.containerView.layer addSublayer:text];
    }
}
- (void)addYScaleLayer {
    CAShapeLayer *yScaleLayer = [CAShapeLayer layer];
    UIBezierPath *yScaleBezier = [UIBezierPath bezierPath];
    [yScaleBezier moveToPoint:CGPointMake(LeftEdge, TopEdge)];
    [yScaleBezier addLineToPoint:CGPointMake(LeftEdge, self.bounds.size.height-BottomEdge)];
    
    for (NSUInteger i=0; i<=_yNegativeSegmentNum+_yPostiveSegmentNum+1; i++) {
        [yScaleBezier moveToPoint:CGPointMake(LeftEdge-5, TopEdge+i*self.yAxisUnitH)];
        [yScaleBezier addLineToPoint:CGPointMake(LeftEdge, TopEdge+i*self.yAxisUnitH)];
    }
    yScaleLayer.path = yScaleBezier.CGPath;
    yScaleLayer.backgroundColor = [UIColor blueColor].CGColor;
    yScaleLayer.lineWidth = 1;
    yScaleLayer.strokeColor = [UIColor blackColor].CGColor;
    yScaleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.containerView.layer addSublayer:yScaleLayer];
    
    if (_showDataDashLine) {
        CAShapeLayer *dashLineLayer = [CAShapeLayer layer];
        UIBezierPath *dashLineBezier = [UIBezierPath bezierPath];
        for (NSUInteger i=0; i<=_yNegativeSegmentNum+_yPostiveSegmentNum; i++) {
            [dashLineBezier moveToPoint:CGPointMake(LeftEdge, TopEdge+i*self.yAxisUnitH)];
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
                                  frame:(CGRect)frame
                          alignmentMode:(NSString *)alignmentMode {
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.frame = frame;
    textLayer.string = text;
    textLayer.fontSize = fontSize;
    textLayer.foregroundColor = textColor.CGColor;
    textLayer.backgroundColor = bgColor.CGColor;
    textLayer.alignmentMode = alignmentMode;
    textLayer.wrapped = YES;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        textLayer.font = (__bridge CFTypeRef _Nullable)(@"PingFangSC-Regular");
    }
    //设置分辨率
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    return textLayer;
}

- (CGFloat)itemW {
    if (_itemW == 0) {
        _itemW = ChartWidth/[self.Datas[0] count] > self.minItemWidth ? (ChartWidth/[self.Datas[0] count]) : self.minItemWidth;
    }
    return _itemW;
}
- (CGFloat)zoomedItemW {
    return self.itemW * self.newPinScale * self.oldPinScale;
}
- (CGFloat)yAxisUnitH {
    return ChartHeight/(_yNegativeSegmentNum + _yPostiveSegmentNum);
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
- (void)defaultColors {
    NSArray *colors = @[@"45abff",@"6be6c1",@"ffa51f",@"ffd64e",@"3fd183",@"6ea7c7",@"5b7cf4",@"00bfd5",@"8bc7ff",@"f48784",@"d25537"];
    NSMutableArray *tempColors = [NSMutableArray arrayWithCapacity:self.Datas.count];
    for (NSUInteger i=0; i<self.Datas.count; i++) {
        [tempColors addObject:colors[i%colors.count]];
    }
    self.itemColors = [tempColors copy];
}
@end
