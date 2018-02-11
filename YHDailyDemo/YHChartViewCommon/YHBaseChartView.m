//
//  YHBaseChartView.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/2/2.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "YHBaseChartView.h"

@interface YHBaseChartView () <UIScrollViewDelegate>

@end

@implementation YHBaseChartView

- (id)initWithFrame:(CGRect)frame configure:(NSDictionary *)configureDict {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self dealChartConfigure:configureDict];
        self.layer.masksToBounds = YES;
        self.pointRatio = YHTapPointRatioInItemMake(0, 0);
    }
    return self;
}
- (void)updateChartFrame:(CGRect)frame {
    self.frame = frame;
    self.gestureScroll.frame = CGRectMake(LeftEdge, RightEdge, [self gestureScrollContentSize].width, [self gestureScrollContentSize].height);
    [self redraw];
}
- (void)dealChartConfigure:(NSDictionary *)dict {
    _AxisArray = [dict objectForKey:@"axis"];
    _Datas = [dict objectForKey:@"datas"];
    _isDataError = !self.AxisArray || ![self.AxisArray isKindOfClass:[NSArray class]] || !self.AxisArray.count ||
                   !self.Datas || ![self.Datas isKindOfClass:[NSArray class]] || !self.Datas.count;

    _groupMembers = [dict objectForKey:@"groupMembers"];
    _axisTitle = [dict objectForKey:@"axisTitle"];
    _dataTitle = [dict objectForKey:@"dataTitle"];
    _itemColors = [dict objectForKey:@"colors"];
    if (!self.itemColors) {
        [self defaultColors];
    }
    BOOL isStack = [[dict objectForKey:@"stack"] boolValue];
    if (isStack) {
        _chartType = BarChartTypeStack;
    } else if (self.Datas.count > 1) {
        _chartType = BarChartTypeGroup;
    } else {
        _chartType = BarChartTypeSingle;
    }
    _valueInterval = [[dict objectForKey:@"valueInterval"] integerValue];
    if (self.valueInterval == 0) {
        _valueInterval = 3;
    }
    NSDictionary *styleDict = [dict objectForKey:@"styles"];
    [self dealStyleDict:styleDict];
}
- (void)dealStyleDict:(NSDictionary *)styleDict {
    _minItemWidth = 20;
    _groupSpace = 5;
    self.showAxisDashLine = NO;
    self.showAxisHardLine = NO;
    self.showDataDashLine = NO;
    self.showDataHardLine = YES;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isDataError) {
        CGRect textFrame = CGRectMake(0, (ChartHeight - TextHeight) / 2.0, ChartWidth, TextHeight);
        CATextLayer *text = [self getTextLayerWithString:@"数据格式有误"
                                               textColor:[UIColor lightGrayColor]
                                                fontSize:TipTextFont
                                         backgroundColor:[UIColor clearColor]
                                                   frame:textFrame
                                           alignmentMode:kCAAlignmentCenter];
        [self.layer addSublayer:text];
        return;
    }
    [self addGestureScroll];
    self.gestureScroll.contentSize = [self gestureScrollContentSize];
    if (!_containerView) {
        [self redraw];
    }
}
- (CGSize)gestureScrollContentSize {
    return CGSizeMake(ChartWidth, ChartHeight);
}
- (void)addGestureScroll {
    if (!_gestureScroll) {
        UIScrollView *scroll =
            [[UIScrollView alloc] initWithFrame:CGRectMake(LeftEdge, TopEdge, ChartWidth, ChartHeight)];
        scroll.showsVerticalScrollIndicator = NO;
        scroll.showsHorizontalScrollIndicator = NO;
        scroll.minimumZoomScale = 1.0;
        scroll.maximumZoomScale = 1.0;
        scroll.bounces = NO;
        scroll.delegate = self;
        scroll.backgroundColor = [UIColor clearColor];
        _gestureScroll = scroll;
        [self addSubview:scroll];

        UIPinchGestureRecognizer *pinGesture =
            [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(chartDidZooming:)];
        [_gestureScroll addGestureRecognizer:pinGesture];

        UITapGestureRecognizer *tapGesture =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chartDidTapping:)];
        tapGesture.numberOfTapsRequired = 1;
        [_gestureScroll addGestureRecognizer:tapGesture];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _newPinScale = 1.0;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self redraw];
}

- (void)chartDidZooming:(UIPinchGestureRecognizer *)pinGesture {
    [self removeTipView];
}

- (void)redraw {
    [_containerView removeFromSuperview];
    _containerView = nil;
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    _containerView.backgroundColor = [UIColor clearColor];

    [self insertSubview:_containerView belowSubview:_gestureScroll];
    [self findBeginAndEndIndex];
    [self calculateMaxAndMinValue];
    [self calculateDataSegment];
    [self addAxisLayer];
    [self addAxisScaleLayer];
    [self addDataLayer];
    [self addDataScaleLayer];
    [self drawDataPoint];
    if (self.hadTapped) {
        [self updateTipLayer:self.tappedGroup item:self.tappedItem];
    }
}
- (void)chartDidTapping:(UITapGestureRecognizer *)tapGesture {
    CGPoint tapP = [tapGesture locationInView:self.gestureScroll];
    NSDictionary *groupItemDict = [self tappedGroupAndItem:tapP];
    _tappedGroup = [[groupItemDict objectForKey:@"group"] integerValue];
    _tappedItem = [[groupItemDict objectForKey:@"item"] integerValue];
    _hadTapped = YES;
    [self saveTapPointRatio:tapP group:_tappedGroup item:_tappedItem];

    [self updateTipLayer:_tappedGroup item:_tappedItem];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapChart:group:item:)]) {
        [self.delegate didTapChart:self group:_tappedGroup item:_tappedItem];
    }
}
- (void)saveTapPointRatio:(CGPoint)tapP group:(NSUInteger)group item:(NSUInteger)item {
    self.pointRatio = YHTapPointRatioInItemMake(0, 0);
}
- (void)removeTipView {
    UIView *existedV = [self.gestureScroll viewWithTag:101];
    [existedV removeFromSuperview];
}
- (NSDictionary *)tappedGroupAndItem:(CGPoint)tapP {
    NSUInteger group = 0, item = 0;
    return @{ @"group": @(group), @"item": @(item) };
}
- (void)updateTipLayer:(NSUInteger)group item:(NSUInteger)item {
    [self removeTipView];
    NSDictionary *dataDict = [self prepareTipViewData:group item:item];
    CGPoint tempP = CGPointFromString([dataDict objectForKey:@"adjustPoint"]);
    NSString *axisStr = [dataDict objectForKey:@"axisStr"];
    NSString *dataStr = [dataDict objectForKey:@"dataStr"];
    
    CGFloat tipTextH = 11;
    CGFloat tipH = 10 + tipTextH + 5;
    CGFloat tipMaxW = [dataStr measureTextWidth:[UIFont systemFontOfSize:9]];
    if (axisStr) {
        tipMaxW = MAX(tipMaxW, [axisStr measureTextWidth:[UIFont systemFontOfSize:9]]);
        tipH += tipTextH;
    }
    tipMaxW += 10;

    NSUInteger arrowP = 2; //箭头在中间位置
    CGFloat originX = tempP.x - tipMaxW / 2.0;
    if (originX < LeftEdge) {
        originX = tempP.x;
        arrowP = 1; //箭头在左边位置
    } else if (tempP.x + tipMaxW / 2.0 > ChartWidth + LeftEdge) {
        originX = tempP.x - tipMaxW;
        arrowP = 3; //箭头在右边位置
    }

    CGFloat originY = tempP.y - tipH;
    if (originY < TopEdge) {
        originY = tempP.y;
        arrowP += 10; //箭头在弹窗上方
    }
    CGPoint contentOffset = self.gestureScroll.contentOffset;
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(contentOffset.x + originX- LeftEdge, contentOffset.y + originY - TopEdge, tipMaxW, tipH)];
    tipView.backgroundColor = [UIColor clearColor];
    tipView.tag = 101;
    [self.gestureScroll addSubview:tipView];

    CAShapeLayer *rectLayer = [CAShapeLayer layer];
    UIBezierPath *rectPath;
    if (arrowP > 10) {
        rectPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 5, tipMaxW, tipH - 5)];
    } else {
        rectPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, tipMaxW, tipH - 5)];
    }
    CGSize cornerRadii = CGSizeMake(5, 5);
    CGRect topRect = CGRectMake(0, 0, tipMaxW, tipH - 5);
    CGRect bottomRect = CGRectMake(0, 5, tipMaxW, tipH - 5);
    switch (arrowP) {
        case 1: { //左下箭头
            rectPath = [UIBezierPath
                bezierPathWithRoundedRect:topRect
                        byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight
                              cornerRadii:cornerRadii];
            [self drawArrow:rectPath
                     startP:CGPointMake(0, tipH - 5)
                    middleP:CGPointMake(0, tipH)
                       endP:CGPointMake(2.5, tipH - 5)];
        } break;
        case 2: { //中下箭头
            rectPath = [UIBezierPath bezierPathWithRoundedRect:topRect
                                             byRoundingCorners:UIRectCornerAllCorners
                                                   cornerRadii:cornerRadii];
            [self drawArrow:rectPath
                     startP:CGPointMake(tipMaxW / 2 - 2.5, tipH - 5)
                    middleP:CGPointMake(tipMaxW / 2, tipH)
                       endP:CGPointMake(tipMaxW / 2 + 2.5, tipH - 5)];
        } break;
        case 3: { //右下箭头
            rectPath = [UIBezierPath
                bezierPathWithRoundedRect:topRect
                        byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft
                              cornerRadii:cornerRadii];
            [self drawArrow:rectPath
                     startP:CGPointMake(tipMaxW - 2.5, tipH - 5)
                    middleP:CGPointMake(tipMaxW, tipH)
                       endP:CGPointMake(tipMaxW, tipH - 5)];
        } break;
        case 11: { //左上箭头
            rectPath = [UIBezierPath
                bezierPathWithRoundedRect:bottomRect
                        byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopRight | UIRectCornerBottomRight
                              cornerRadii:cornerRadii];
            [self drawArrow:rectPath startP:CGPointMake(0, 5) middleP:CGPointMake(0, 0) endP:CGPointMake(2.5, 5)];
        } break;
        case 12: { //中上箭头
            rectPath = [UIBezierPath bezierPathWithRoundedRect:bottomRect
                                             byRoundingCorners:UIRectCornerAllCorners
                                                   cornerRadii:cornerRadii];
            [self drawArrow:rectPath
                     startP:CGPointMake(tipMaxW / 2 - 2.5, 5)
                    middleP:CGPointMake(tipMaxW / 2, 0)
                       endP:CGPointMake(tipMaxW / 2 + 2.5, 5)];
        } break;
        case 13: { //右上箭头
            rectPath = [UIBezierPath
                bezierPathWithRoundedRect:bottomRect
                        byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight
                              cornerRadii:cornerRadii];
            [self drawArrow:rectPath
                     startP:CGPointMake(tipMaxW - 2.5, 5)
                    middleP:CGPointMake(tipMaxW, 0)
                       endP:CGPointMake(tipMaxW, 5)];
        } break;

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
        textFrame = CGRectMake(5, startY, tipMaxW - 10, tipTextH);
        CATextLayer *text = [self getTextLayerWithString:axisStr
                                               textColor:TipTextColor
                                                fontSize:TipTextFont
                                         backgroundColor:[UIColor clearColor]
                                                   frame:textFrame
                                           alignmentMode:kCAAlignmentLeft];
        [tipView.layer addSublayer:text];
    }
    if (textFrame.origin.x > 0) {
        CATextLayer *text = [self getTextLayerWithString:dataStr
                                               textColor:TipTextColor
                                                fontSize:TipTextFont
                                         backgroundColor:[UIColor clearColor]
                                                   frame:CGRectMake(5, CGRectGetMaxY(textFrame), tipMaxW - 10, tipTextH)
                                           alignmentMode:kCAAlignmentLeft];
        [tipView.layer addSublayer:text];
    } else {
        CATextLayer *text = [self getTextLayerWithString:axisStr
                                               textColor:TipTextColor
                                                fontSize:TipTextFont
                                         backgroundColor:[UIColor clearColor]
                                                   frame:CGRectMake(5, startY, tipMaxW - 10, tipTextH)
                                           alignmentMode:kCAAlignmentLeft];
        [tipView.layer addSublayer:text];
    }
}
- (void)drawArrow:(UIBezierPath *)path startP:(CGPoint)startP middleP:(CGPoint)middleP endP:(CGPoint)endP {
    [path moveToPoint:startP];
    [path addLineToPoint:middleP];
    [path addLineToPoint:endP];
}

- (NSDictionary *)prepareTipViewData:(NSUInteger)group item:(NSUInteger)item containerPoint:(CGPoint)point {
    CGPoint tempP = point;

    NSString *axisStr = [NSString stringWithFormat:@"%@: %@", self.axisTitle, self.AxisArray[group]];
    NSString *dataStr =
        [NSString stringWithFormat:@"%@: %@", self.groupMembers[item], [self.Datas[item] objectAtIndex:group]];
    return @{ @"adjustPoint": NSStringFromCGPoint(tempP), @"axisStr": axisStr, @"dataStr": dataStr };
}

- (void)findBeginAndEndIndex {
    [self findGroupAndItemIndex];

    if (self.beginGroupIndex < 0) {
        self.beginGroupIndex = 0;
    }
    if (self.beginItemIndex < 0) {
        self.beginItemIndex = 0;
    }
    if (self.beginItemIndex > self.Datas.count) {
        self.beginItemIndex = self.Datas.count - 1;
    }
    if (self.endItemIndex < 0) {
        self.endItemIndex = 0;
    }
    if (self.endItemIndex > self.Datas.count) {
        self.endItemIndex = self.Datas.count - 1;
    }

    if (self.endGroupIndex > [self.Datas[0] count] - 1) {
        self.endGroupIndex = [self.Datas[0] count] - 1;
    }
    if (self.beginGroupIndex > self.endGroupIndex) {
        self.beginGroupIndex = self.endGroupIndex;
    }
}
- (void)findGroupAndItemIndex {
    self.beginGroupIndex = 0;
    self.endGroupIndex = 0;
    self.beginItemIndex = 0;
    self.endItemIndex = 0;
}
- (void)calculateMaxAndMinValue {
    self.minDataValue = 0;
    self.maxDataValue = 0;
}
- (void)compareBeginAndEndItemValue:(NSUInteger)beginItem endItem:(NSUInteger)endItem isBeginGroup:(BOOL)isBeginGroup {
    for (NSUInteger i = beginItem; i <= endItem; i++) {
        NSUInteger index = isBeginGroup ? self.beginGroupIndex : self.endGroupIndex;
        CGFloat tempValue = [[self.Datas[i] objectAtIndex:index] floatValue];
        self.minDataValue = MIN(self.minDataValue, tempValue);
        self.maxDataValue = MAX(self.maxDataValue, tempValue);
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
        self.minDataValue = MIN([compareA[leftIndex] floatValue], self.minDataValue);
        self.maxDataValue = MAX([compareA[leftIndex] floatValue], self.maxDataValue);
        return;
    } else if (leftIndex == rightIndex - 1) {
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
    NSUInteger mid = (leftIndex + rightIndex) / 2;
    [self findMaxAndMinValue:leftIndex rightIndex:mid compareA:compareA];
    [self findMaxAndMinValue:mid + 1 rightIndex:rightIndex compareA:compareA];
}

- (void)calculateDataSegment {
    if (self.minDataValue >= 0) {
        _dataPostiveSegmentNum = self.valueInterval;
        if (self.maxDataValue < 1) {
            _dataPostiveSegmentNum = 1;
        }
        _dataNegativeSegmentNum = 0;
        self.itemDataScale = ceil([self absoluteMaxValue:self.maxDataValue] / _dataPostiveSegmentNum);
    } else if (self.maxDataValue < 0) {
        _dataPostiveSegmentNum = 0;
        _dataNegativeSegmentNum = self.valueInterval;
        if (fabs(self.minDataValue) < 1) {
            _dataNegativeSegmentNum = 1;
        }
        self.itemDataScale = ceil([self absoluteMaxValue:self.minDataValue] / _dataNegativeSegmentNum);
    } else if (self.maxDataValue >= fabs(self.minDataValue)) {
        _dataPostiveSegmentNum = self.valueInterval;
        if (self.maxDataValue < 1) {
            _dataPostiveSegmentNum = 1;
        }
        self.itemDataScale = ceil([self absoluteMaxValue:self.maxDataValue] / _dataPostiveSegmentNum);
        _dataNegativeSegmentNum = ceil(fabs(self.minDataValue) / self.itemDataScale);
    } else {
        _dataNegativeSegmentNum = self.valueInterval;
        if (fabs(self.minDataValue) < 1) {
            _dataNegativeSegmentNum = 1;
        }
        self.itemDataScale = ceil([self absoluteMaxValue:self.minDataValue] / _dataNegativeSegmentNum);
        _dataPostiveSegmentNum = ceil(self.maxDataValue / self.itemDataScale);
    }
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
}

- (void)addAxisLayer {
}
- (void)addAxisScaleLayer {
}
- (void)addDataLayer {
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

- (CGFloat)calculateItemAxisScale {
    return 0;
}
- (CGFloat)zoomedItemAxis {
    return [self calculateItemAxisScale] * self.newPinScale * self.oldPinScale;
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
    NSArray *colors = @[
        @"45abff", @"6be6c1", @"ffa51f", @"ffd64e", @"3fd183", @"6ea7c7", @"5b7cf4", @"00bfd5", @"8bc7ff", @"f48784",
        @"d25537"
    ];
    NSMutableArray *tempColors = [NSMutableArray arrayWithCapacity:self.Datas.count];
    for (NSUInteger i = 0; i < self.Datas.count; i++) {
        [tempColors addObject:colors[i % colors.count]];
    }
    _itemColors = [tempColors copy];
}

- (CGFloat)dataItemUnitScale {
    return 0;
}

- (CGFloat)dataAtGroup:(NSUInteger)group item:(NSUInteger)item {
    return [[self.Datas[item] objectAtIndex:group] floatValue];
}
@end
