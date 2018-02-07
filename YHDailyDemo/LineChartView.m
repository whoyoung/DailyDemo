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
static const float ReferenceLineWidth = 1;

#define ChartWidth (self.bounds.size.width-LeftEdge-RightEdge)
#define ChartHeight (self.bounds.size.height-TopEdge-BottomEdge)
#define AxisTextColor [UIColor hexChangeFloat:@"8899A6"]
#define AxisScaleColor [UIColor hexChangeFloat:@"EEEEEE"]
#define DataTextColor [UIColor hexChangeFloat:@"8FA1B2"]
#define TipTextColor [UIColor whiteColor]

#import "LineChartView.h"
#import "UIColor+HexColor.h"
#import "NSString+Extra.h"
@interface LineChartView()<UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *gestureScroll;
@property (nonatomic, strong) NSMutableArray<NSString *> *AxisArray;
@property (nonatomic, strong) NSArray<NSArray *> *Datas;

@property (nonatomic, assign) NSInteger beginIndex;
@property (nonatomic, assign) NSInteger endIndex;
@property (nonatomic, assign) CGFloat itemAxisScale;
@property (nonatomic, assign) NSUInteger itemDataScale;
@property (nonatomic, assign) CGFloat maxDataValue;
@property (nonatomic, assign) CGFloat minDataValue;

@property (nonatomic, assign) NSUInteger dataPostiveSegmentNum;
@property (nonatomic, assign) NSUInteger dataNegativeSegmentNum;

@property (nonatomic, assign) CGFloat dataItemUnitScale;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, assign) CGFloat oldPinScale;
@property (nonatomic, assign) CGFloat newPinScale;
@property (nonatomic, assign) CGFloat pinCenterToLeftDistance;
@property (nonatomic, assign) CGFloat pinCenterRatio;
@property (nonatomic, assign) CGFloat zoomedItemAxis;

@property (nonatomic, assign) BOOL isDataError;
@property (nonatomic, strong) NSArray *groupMembers;
@property (nonatomic, copy) NSString *axisTitle;
@property (nonatomic, copy) NSString *dataTitle;
@property (nonatomic, strong) NSArray *itemColors;
@property (nonatomic, assign) NSUInteger valueInterval;
@property (nonatomic, assign) CGFloat zeroLine;
@property (nonatomic, assign) BOOL showDataDashLine;
@property (nonatomic, assign) BOOL showDataHardLine;
@property (nonatomic, assign) BOOL showAxisDashLine;
@property (nonatomic, assign) BOOL showAxisHardLine;
@property (nonatomic, assign) BOOL showDataEdgeLine;
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
    self.showAxisDashLine = [lineStyle objectForKey:@"showAxisDashLine"] ? [[lineStyle objectForKey:@"showAxisDashLine"] boolValue] : NO;
    self.showAxisHardLine = [lineStyle objectForKey:@"showAxisHardLine"] ? [[lineStyle objectForKey:@"showAxisHardLine"] boolValue] : NO;
    self.showDataDashLine = [lineStyle objectForKey:@"showDataDashLine"] ? [[lineStyle objectForKey:@"showDataDashLine"] boolValue] : NO;
    self.showDataHardLine = [lineStyle objectForKey:@"showDataHardLine"] ? [[lineStyle objectForKey:@"showDataHardLine"] boolValue] : YES;

}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isDataError) {
        CGRect textFrame = CGRectMake(0,( ChartHeight-TextHeight)/2.0, ChartWidth, TextHeight);
        CATextLayer *text = [self getTextLayerWithString:@"数据格式有误" textColor:[UIColor lightGrayColor] fontSize:TipTextFont backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentCenter];
        [self.layer addSublayer:text];
        return;
    }
    [self addGestureScroll];
    self.gestureScroll.contentSize = CGSizeMake([self.Datas[0] count]*self.zoomedItemAxis, ChartHeight);
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
            if (pinGesture.scale < 1 && [self.Datas[0] count]*self.itemAxisScale*_oldPinScale*pinGesture.scale <= ChartWidth) {
                _newPinScale = ChartWidth/([self.Datas[0] count]*self.itemAxisScale*_oldPinScale);
            } else {
                _newPinScale = pinGesture.scale;
            }
            [self adjustScroll];
            [self redraw];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            _oldPinScale *= _newPinScale;
            _newPinScale = 1.0;
        }
            break;
            
        default:
            break;
    }
}
- (void)adjustScroll {
    self.gestureScroll.contentSize = CGSizeMake([self.Datas[0] count]*self.zoomedItemAxis, ChartHeight);
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
    
    NSUInteger group = 0, item = 0;
    group = floorf(tapP.x / self.zoomedItemAxis);
    if ((tapP.x - group * self.zoomedItemAxis) > self.zoomedItemAxis/2.0 && group <  self.Datas[0].count - 1) {
        group += 1;
    }
    if (self.Datas.count > 1) {
        CGFloat actualY = self.zeroLine - [[self.Datas[0] objectAtIndex:group] floatValue] * _dataItemUnitScale;
        CGFloat minDistance = fabs(tapP.y - actualY);
        for (NSUInteger i=1; i<self.Datas.count; i++) {
            CGFloat tempActualY = self.zeroLine - [[self.Datas[i] objectAtIndex:group] floatValue] * _dataItemUnitScale;
            if (minDistance > fabs(tapP.y - tempActualY)) {
                minDistance = fabs(tapP.y - tempActualY);
                item = i;
            }
        }
    }
    if (item > self.Datas.count - 1) {
        item = self.Datas.count - 1;
    }
    
    CGPoint containerP = [tapGesture locationInView:self.containerView];
    [self updateTipLayer:group item:item containerPoint:containerP];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapChart:group:item:)]) {
        [self.delegate didTapChart:self group:group item:item];
    }
}
- (void)updateTipLayer:(NSUInteger)group item:(NSUInteger)item containerPoint:(CGPoint)point {
    CGPoint tempP = point;
    CGFloat absoluteZeroLine = self.zeroLine + TopEdge;
    tempP.x = group * self.zoomedItemAxis + LeftEdge;
    tempP.y = absoluteZeroLine - [[self.Datas[item] objectAtIndex:group] floatValue] * _dataItemUnitScale;
    
    NSString *axisStr;
    NSString *dataStr = [NSString stringWithFormat:@"%@: %@",self.dataTitle,[self.Datas[item] objectAtIndex:group]];
    if (self.Datas.count < 2) {
        dataStr = [NSString stringWithFormat:@"%@: %@",self.AxisArray[group],[self.Datas[item] objectAtIndex:group]];
    } else {
        axisStr = [NSString stringWithFormat:@"%@: %@",self.axisTitle,self.AxisArray[group]];
        dataStr = [NSString stringWithFormat:@"%@: %@",self.groupMembers[item],[self.Datas[item] objectAtIndex:group]];
    }
    CGFloat tipTextH = 11;
    CGFloat tipH = 10 + tipTextH + 5;
    CGFloat tipMaxW = [dataStr measureTextWidth:[UIFont systemFontOfSize:TipTextFont]];
    if (axisStr) {
        tipMaxW = MAX(tipMaxW, [axisStr measureTextWidth:[UIFont systemFontOfSize:TipTextFont]]);
        tipH += tipTextH;
    }
    tipMaxW += 10;
    
    NSUInteger arrowP = 2; //箭头在中间位置
    CGFloat originX = tempP.x - tipMaxW/2.0;
    if (originX < LeftEdge) {
        originX = tempP.x;
        arrowP = 1; //箭头在左边位置
    } else if (tempP.x + tipMaxW/2.0 > ChartWidth + LeftEdge) {
        originX = tempP.x - tipMaxW;
        arrowP = 3; //箭头在右边位置
    }
    
    CGFloat originY = tempP.y - tipH;
    if (originY < TopEdge) {
        originY = tempP.y;
        arrowP += 10; //箭头在弹窗上方
    }
    
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(originX, originY, tipMaxW, tipH)];
    tipView.backgroundColor = [UIColor  clearColor];
    tipView.tag = 101;
    [self.containerView addSubview:tipView];
    
    CAShapeLayer *rectLayer = [CAShapeLayer layer];
    UIBezierPath *rectPath;
    if (arrowP > 10) {
        rectPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 5, tipMaxW, tipH-5)];
    } else {
        rectPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, tipMaxW, tipH-5)];
    }
    CGSize cornerRadii = CGSizeMake(5, 5);
    CGRect topRect = CGRectMake(0, 0, tipMaxW, tipH-5);
    CGRect bottomRect = CGRectMake(0, 5, tipMaxW, tipH-5);
    switch (arrowP) {
        case 1: { //左下箭头
            rectPath = [UIBezierPath bezierPathWithRoundedRect:topRect byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:cornerRadii];
            [self drawArrow:rectPath startP:CGPointMake(0, tipH-5) middleP:CGPointMake(0, tipH) endP:CGPointMake(2.5, tipH-5)];
        }
            break;
        case 2: { //中下箭头
            rectPath = [UIBezierPath bezierPathWithRoundedRect:topRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:cornerRadii];
            [self drawArrow:rectPath startP:CGPointMake(tipMaxW/2-2.5, tipH-5) middleP:CGPointMake(tipMaxW/2, tipH) endP:CGPointMake(tipMaxW/2+2.5, tipH-5)];
        }
            break;
        case 3: { //右下箭头
            rectPath = [UIBezierPath bezierPathWithRoundedRect:topRect byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomLeft cornerRadii:cornerRadii];
            [self drawArrow:rectPath startP:CGPointMake(tipMaxW-2.5, tipH-5) middleP:CGPointMake(tipMaxW, tipH) endP:CGPointMake(tipMaxW, tipH-5)];
        }
            break;
        case 11: { //左上箭头
            rectPath = [UIBezierPath bezierPathWithRoundedRect:bottomRect byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:cornerRadii];
            [self drawArrow:rectPath startP:CGPointMake(0, 5) middleP:CGPointMake(0, 0) endP:CGPointMake(2.5, 5)];
        }
            break;
        case 12: { //中上箭头
            rectPath = [UIBezierPath bezierPathWithRoundedRect:bottomRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:cornerRadii];
            [self drawArrow:rectPath startP:CGPointMake(tipMaxW/2-2.5, 5) middleP:CGPointMake(tipMaxW/2, 0) endP:CGPointMake(tipMaxW/2+2.5, 5)];
        }
            break;
        case 13: { //右上箭头
            rectPath = [UIBezierPath bezierPathWithRoundedRect:bottomRect byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:cornerRadii];
            [self drawArrow:rectPath startP:CGPointMake(tipMaxW-2.5, 5) middleP:CGPointMake(tipMaxW, 0) endP:CGPointMake(tipMaxW, 5)];
        }
            break;
            
        default:
            break;
    }
    rectLayer.path = rectPath.CGPath;
    rectLayer.fillColor = [UIColor hexChangeFloat:@"0D2940"].CGColor;
    [tipView.layer addSublayer:rectLayer];
    
    CGRect textFrame = CGRectZero;
    CGFloat startY = 5;
    if (arrowP > 10) {
        startY = 10;
    }
    if (axisStr) {
        textFrame = CGRectMake(5, startY, tipMaxW-10, tipTextH);
        CATextLayer *text = [self getTextLayerWithString:axisStr textColor:TipTextColor fontSize:TipTextFont backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentLeft];
        [tipView.layer addSublayer:text];
    }
    if (textFrame.origin.x > 0) {
        CATextLayer *text = [self getTextLayerWithString:dataStr textColor:TipTextColor fontSize:TipTextFont backgroundColor:[UIColor clearColor] frame:CGRectMake(5, CGRectGetMaxY(textFrame), tipMaxW-10, tipTextH) alignmentMode:kCAAlignmentLeft];
        [tipView.layer addSublayer:text];
    } else {
        CATextLayer *text = [self getTextLayerWithString:axisStr textColor:TipTextColor fontSize:TipTextFont backgroundColor:[UIColor clearColor] frame:CGRectMake(5, startY, tipMaxW-10, tipTextH) alignmentMode:kCAAlignmentLeft];
        [tipView.layer addSublayer:text];
    }
}
- (void)drawArrow:(UIBezierPath *)path startP:(CGPoint)startP middleP:(CGPoint)middleP endP:(CGPoint)endP {
    [path moveToPoint:startP];
    [path addLineToPoint:middleP];
    [path addLineToPoint:endP];
}
- (void)removeTipView {
    UIView *existedV = [self.containerView viewWithTag:101];
    [existedV removeFromSuperview];
}
- (void)redraw {
    [_containerView removeFromSuperview];
    _containerView = nil;
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    _containerView.backgroundColor = [UIColor whiteColor];
    
    [self insertSubview:_containerView belowSubview:_gestureScroll];
    [self findBeginAndEndIndex];
    
    [self campareMaxAndMinValue];
    [self calculateDataSegment];
    [self addAxisLayer];
    [self addAxisScaleLayer];
    [self addDataLayer];
    [self addDataScaleLayer];
    [self drawDataPoint];
}

- (void)findBeginAndEndIndex {
    CGPoint offset = self.gestureScroll.contentOffset;
    self.beginIndex = floor(offset.x/self.zoomedItemAxis);
    self.endIndex = ceil((offset.x+ChartWidth)/self.zoomedItemAxis);
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

- (void)campareMaxAndMinValue {
    self.minDataValue = [self.Datas[0][_beginIndex] floatValue];
    self.maxDataValue = self.minDataValue;
    for (NSArray *values in self.Datas) {
        [self findMaxAndMinValue:self.beginIndex rightIndex:self.endIndex compareA:values];
    }
}
- (void)findMaxAndMinValue:(NSUInteger)leftIndex rightIndex:(NSUInteger)rightIndex compareA:(NSArray *)compareA {
    if (leftIndex > rightIndex) {
        leftIndex = rightIndex;
    }
    if (leftIndex == rightIndex) {
        self.minDataValue = MIN([compareA[leftIndex] floatValue], self.minDataValue);
        self.maxDataValue = MAX([compareA[leftIndex] floatValue], self.maxDataValue);
        return;
    } else if(leftIndex == rightIndex-1) {
        if ([compareA[leftIndex] floatValue] < [compareA[rightIndex] floatValue]) {
            self.minDataValue = MIN([compareA[leftIndex] floatValue], self.minDataValue);
            self.maxDataValue = MAX([compareA[rightIndex] floatValue], self.maxDataValue);
            return;
        } else {
            self.minDataValue = MIN([compareA[rightIndex] floatValue], self.minDataValue);
            self.maxDataValue = MAX([compareA[leftIndex] floatValue], self.maxDataValue);
            return;
        }
    }
    NSUInteger mid = (leftIndex + rightIndex)/2;
    [self findMaxAndMinValue:leftIndex rightIndex:mid compareA:compareA];
    [self findMaxAndMinValue:mid + 1 rightIndex:rightIndex compareA:compareA];
}

- (void)calculateDataSegment {
    if (self.minDataValue >= 0) {
        self.dataPostiveSegmentNum = 4;
        if(self.maxDataValue < 1) self.dataPostiveSegmentNum = 1;
        self.dataNegativeSegmentNum = 0;
        self.itemDataScale = ceil([self absoluteMaxValue:self.maxDataValue]/self.dataPostiveSegmentNum);
    } else if (self.maxDataValue < 0) {
        self.dataPostiveSegmentNum = 0;
        self.dataNegativeSegmentNum = 4;
        if(fabs(self.minDataValue) < 1) self.dataNegativeSegmentNum = 1;
        self.itemDataScale = ceil([self absoluteMaxValue:self.minDataValue]/self.dataNegativeSegmentNum);
    } else if (self.maxDataValue >= fabs(self.minDataValue)) {
        self.dataPostiveSegmentNum = 4;
        if(self.maxDataValue < 1) self.dataPostiveSegmentNum = 1;
        self.itemDataScale = ceil([self absoluteMaxValue:self.maxDataValue]/self.dataPostiveSegmentNum);
        self.dataNegativeSegmentNum = ceil(fabs(self.minDataValue)/self.itemDataScale);
    } else {
        self.dataNegativeSegmentNum = 4;
        if(fabs(self.minDataValue) < 1) self.dataNegativeSegmentNum = 1;
        self.itemDataScale = ceil([self absoluteMaxValue:self.minDataValue] /self.dataNegativeSegmentNum);
        self.dataPostiveSegmentNum = ceil(self.maxDataValue/self.itemDataScale);
    }
    self.dataItemUnitScale = ChartHeight/(self.itemDataScale * (self.dataPostiveSegmentNum+self.dataNegativeSegmentNum));
}
- (NSUInteger)absoluteMaxValue:(CGFloat)value {
    CGFloat maxNum = fabs(value);
    NSString *str = [NSString stringWithFormat:@"%.0f", floorf(maxNum)];
    NSUInteger tenCube = 1;
    if (str.length > 2) {
        tenCube = pow(10, str.length - 2);
    }
    return ceil(ceil(maxNum / tenCube) / self.valueInterval) * self.valueInterval * tenCube;
}
- (void)drawDataPoint {
    UIView *subContainerV = [[UIView alloc] initWithFrame:CGRectMake(LeftEdge, TopEdge, ChartWidth, ChartHeight)];
    subContainerV.layer.masksToBounds = YES;
    [self.containerView addSubview:subContainerV];
    for (NSUInteger i=0;i<self.Datas.count;i++) {
        NSArray *values = self.Datas[i];
        CAShapeLayer *yValueLayer = [CAShapeLayer layer];
        UIBezierPath *yValueBezier = [UIBezierPath bezierPath];
        CGFloat offsetX = self.gestureScroll.contentOffset.x;
        CGFloat zeroY = _dataPostiveSegmentNum * [self axisUnitScale];
        for (NSUInteger i=self.beginIndex; i<self.endIndex+1; i++) {
            CGFloat yPoint = zeroY - [values[i] floatValue] * _dataItemUnitScale;
            CGPoint p = CGPointMake(i*self.zoomedItemAxis-offsetX, yPoint);
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

- (void)addAxisLayer {
    CGFloat offsetX = self.gestureScroll.contentOffset.x;
    for (NSUInteger i=_beginIndex; i<=_endIndex; i++) {
        if (self.zoomedItemAxis*i-offsetX < 0) continue;
        CGRect textFrame = CGRectMake(LeftEdge + self.zoomedItemAxis*i-offsetX-self.zoomedItemAxis/2.0, self.bounds.size.height-TextHeight, self.zoomedItemAxis, TextHeight);
        CATextLayer *text = [self getTextLayerWithString:self.AxisArray[i] textColor:AxisTextColor fontSize:AxistTextFont backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentCenter];
        [self.containerView.layer addSublayer:text];
    }
}
- (void)addAxisScaleLayer {
    CAShapeLayer *xScaleLayer = [CAShapeLayer layer];
    UIBezierPath *xScaleBezier = [UIBezierPath bezierPath];
    [xScaleBezier moveToPoint:CGPointMake(LeftEdge, self.bounds.size.height-BottomEdge)];
    [xScaleBezier addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height-BottomEdge)];
    
    CGFloat offsetX = self.gestureScroll.contentOffset.x;
    for (NSUInteger i=_beginIndex; i<=_endIndex; i++) {
        if (self.zoomedItemAxis*i - offsetX < 0) continue;
        [xScaleBezier moveToPoint:CGPointMake(LeftEdge + self.zoomedItemAxis*i - offsetX, self.bounds.size.height-BottomEdge)];
        [xScaleBezier addLineToPoint:CGPointMake(LeftEdge + self.zoomedItemAxis*i - offsetX, self.bounds.size.height-BottomEdge+5)];
    }
    xScaleLayer.path = xScaleBezier.CGPath;
    xScaleLayer.lineWidth = ReferenceLineWidth;
    xScaleLayer.strokeColor = AxisScaleColor.CGColor;
    xScaleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.containerView.layer addSublayer:xScaleLayer];
    
    if (_showAxisDashLine || _showAxisHardLine) {
        CAShapeLayer *dashLineLayer = [CAShapeLayer layer];
        UIBezierPath *dashLineBezier = [UIBezierPath bezierPath];
        for (NSUInteger i=_beginIndex; i<=_endIndex; i++) {
            if (self.zoomedItemAxis*i - offsetX < 0) continue;
            [dashLineBezier moveToPoint:CGPointMake(LeftEdge + self.zoomedItemAxis*i - offsetX, self.bounds.size.height-BottomEdge-1)];
            [dashLineBezier addLineToPoint:CGPointMake(LeftEdge + self.zoomedItemAxis*i - offsetX, TopEdge)];
        }
        dashLineLayer.path = dashLineBezier.CGPath;
        if (_showAxisDashLine) {
            [dashLineLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:5], nil]];
        }
        dashLineLayer.lineWidth = ReferenceLineWidth;
        dashLineLayer.strokeColor = AxisScaleColor.CGColor;
        dashLineLayer.fillColor = [UIColor clearColor].CGColor;
        [self.containerView.layer addSublayer:dashLineLayer];
    }
}
- (void)addDataLayer {
    for (NSUInteger i=0; i<_dataNegativeSegmentNum; i++) {
        CGRect textFrame = CGRectMake(0, self.bounds.size.height-1.5*BottomEdge-i*[self axisUnitScale], TextWidth, BottomEdge);
        CATextLayer *text = [self getTextLayerWithString:[NSString stringWithFormat:@"-%@",[self adjustScaleValue:(_dataNegativeSegmentNum-i)*_itemDataScale]] textColor:DataTextColor fontSize:DataTextFont backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentRight];
        [self.containerView.layer addSublayer:text];
    }
    for (NSInteger i=0; i<=_dataPostiveSegmentNum+1; i++) {
        CGRect textFrame = CGRectMake(0, self.bounds.size.height-1.5*BottomEdge-(_dataNegativeSegmentNum+i)*[self axisUnitScale], TextWidth, BottomEdge);
        CATextLayer *text = [self getTextLayerWithString:[NSString stringWithFormat:@"%@",[self adjustScaleValue:i*_itemDataScale]] textColor:DataTextColor fontSize:DataTextFont backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentRight];
        [self.containerView.layer addSublayer:text];
    }
}
- (NSString *)adjustScaleValue:(NSUInteger)scaleValue {
    NSString *tempStr = [NSString stringWithFormat:@"%lu", scaleValue];
    NSUInteger length = tempStr.length;
    if (3 < length && length < 7) {
        if ([[tempStr substringWithRange:NSMakeRange(length - 3, 3)] isEqualToString:@"000"]) {
            return [NSString stringWithFormat:@"%@K", [tempStr substringToIndex:length - 3]];
        }
    } else if (length > 6 && length < 10) {
        if ([[tempStr substringWithRange:NSMakeRange(length - 6, 6)] isEqualToString:@"000000"]) {
            return [NSString stringWithFormat:@"%@M", [tempStr substringToIndex:length - 6]];
        } else if ([[tempStr substringWithRange:NSMakeRange(length - 3, 3)] isEqualToString:@"000"]) {
            return [NSString stringWithFormat:@"%@K", [tempStr substringToIndex:length - 3]];
        }
    } else if (length > 9) {
        if ([[tempStr substringWithRange:NSMakeRange(length - 9, 9)] isEqualToString:@"000000000"]) {
            return [NSString stringWithFormat:@"%@B", [tempStr substringToIndex:length - 9]];
        } else if ([[tempStr substringWithRange:NSMakeRange(length - 6, 6)] isEqualToString:@"000000"]) {
            return [NSString stringWithFormat:@"%@M", [tempStr substringToIndex:length - 6]];
        } else if ([[tempStr substringWithRange:NSMakeRange(length - 3, 3)] isEqualToString:@"000"]) {
            return [NSString stringWithFormat:@"%@K", [tempStr substringToIndex:length - 3]];
        }
    }
    return tempStr;
}
- (void)addDataScaleLayer {
    if (_showDataEdgeLine) {
        CAShapeLayer *yScaleLayer = [CAShapeLayer layer];
        UIBezierPath *yScaleBezier = [UIBezierPath bezierPath];
        [yScaleBezier moveToPoint:CGPointMake(LeftEdge, TopEdge)];
        [yScaleBezier addLineToPoint:CGPointMake(LeftEdge, self.bounds.size.height-BottomEdge)];
        
        for (NSUInteger i=0; i<=_dataNegativeSegmentNum+_dataPostiveSegmentNum+1; i++) {
            [yScaleBezier moveToPoint:CGPointMake(LeftEdge-5, TopEdge+i*[self axisUnitScale])];
            [yScaleBezier addLineToPoint:CGPointMake(LeftEdge, TopEdge+i*[self axisUnitScale])];
        }
        yScaleLayer.path = yScaleBezier.CGPath;
        yScaleLayer.backgroundColor = [UIColor blueColor].CGColor;
        yScaleLayer.lineWidth = ReferenceLineWidth;
        yScaleLayer.strokeColor = AxisScaleColor.CGColor;
        yScaleLayer.fillColor = [UIColor clearColor].CGColor;
        [self.containerView.layer addSublayer:yScaleLayer];
    }
    
    if (_showDataDashLine || _showDataHardLine) {
        CAShapeLayer *dashLineLayer = [CAShapeLayer layer];
        UIBezierPath *dashLineBezier = [UIBezierPath bezierPath];
        for (NSUInteger i=0; i<=_dataNegativeSegmentNum+_dataPostiveSegmentNum; i++) {
            [dashLineBezier moveToPoint:CGPointMake(LeftEdge, TopEdge+i*[self axisUnitScale])];
            [dashLineBezier addLineToPoint:CGPointMake(self.bounds.size.width, TopEdge+i*[self axisUnitScale])];
        }
        dashLineLayer.path = dashLineBezier.CGPath;
        if (_showDataDashLine) {
            [dashLineLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:5], nil]];
        }
        dashLineLayer.lineWidth = ReferenceLineWidth;
        dashLineLayer.strokeColor = AxisScaleColor.CGColor;
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

- (CGFloat)itemAxisScale {
    if (_itemAxisScale == 0) {
        _itemAxisScale = ChartWidth/[self.Datas[0] count] > self.minItemWidth ? (ChartWidth/[self.Datas[0] count]) : self.minItemWidth;
    }
    return _itemAxisScale;
}
- (CGFloat)zoomedItemAxis {
    return self.itemAxisScale * self.newPinScale * self.oldPinScale;
}
- (CGFloat)axisUnitScale {
    return ChartHeight/(_dataNegativeSegmentNum + _dataPostiveSegmentNum);
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
- (CGFloat)zeroLine {
    return self.dataPostiveSegmentNum * [self axisUnitScale];
}
@end
