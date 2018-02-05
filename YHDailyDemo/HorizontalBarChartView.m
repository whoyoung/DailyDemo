//
//  HorizontalBarChartView.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/1/30.
//  Copyright © 2018年 杨虎. All rights reserved.
//
static const float TopEdge = 10;
static const float LeftEdge = 50;
static const float RightEdge = 10;
static const float BottomEdge = 20;
static const float TextHeight = 15;
static const float TextWidth = 45;
#define ChartWidth (self.bounds.size.width-LeftEdge-RightEdge)
#define ChartHeight (self.bounds.size.height-TopEdge-BottomEdge)

#import "HorizontalBarChartView.h"
#import "UIColor+HexColor.h"

typedef NS_ENUM(NSUInteger,BarChartType) {
    BarChartTypeSingle = 0,
    BarChartTypeGroup = 1,
    BarChartTypeStack = 2
};

@interface HorizontalBarChartView()<UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *gestureScroll;
@property (nonatomic, assign) CGFloat scrollContentSizeWidth;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) NSMutableArray<NSString *> *AxisArray;
@property (nonatomic, strong) NSArray<NSArray *> *Datas;
@property (nonatomic, strong) NSArray *groupMembers;
@property (nonatomic, copy) NSString *axisTitle;
@property (nonatomic, copy) NSString *dataTitles;
@property (nonatomic, strong) NSArray *barColors;
@property (nonatomic, assign) BarChartType chartType;
@property (nonatomic, assign) CGFloat minBarWidth;
@property (nonatomic, assign) CGFloat groupSpace;
@property (nonatomic, assign) NSUInteger valueInterval;
@property (nonatomic, assign) BOOL showDataDashLine;

@property (nonatomic, assign) NSInteger beginGroupIndex;
@property (nonatomic, assign) NSInteger endGroupIndex;
@property (nonatomic, assign) NSInteger beginItemIndex;
@property (nonatomic, assign) NSInteger endItemIndex;
@property (nonatomic, assign) CGFloat itemW;
@property (nonatomic, assign) NSUInteger itemH;
@property (nonatomic, assign) CGFloat maxDataValue;
@property (nonatomic, assign) CGFloat minDataValue;

@property (nonatomic, assign) NSUInteger dataPostiveSegmentNum;
@property (nonatomic, assign) NSUInteger dataNegativeSegmentNum;

@property (nonatomic, assign) CGFloat dataItemUnitH;

@property (nonatomic, assign) CGFloat oldPinScale;
@property (nonatomic, assign) CGFloat newPinScale;
@property (nonatomic, assign) CGFloat pinCenterToLeftDistance;
@property (nonatomic, assign) CGFloat pinCenterRatio;
@property (nonatomic, assign) CGFloat zoomedItemW;

@property (nonatomic, assign) BOOL isDataError;
@end

@implementation HorizontalBarChartView

- (id)initWithFrame:(CGRect)frame configure:(NSDictionary *)configureDict {
    self = [super initWithFrame:frame];
    if (self) {
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
    self.dataTitles = [dict objectForKey:@"dataTitles"];
    self.barColors = [dict objectForKey:@"colors"];
    if (!self.barColors) {
        [self defaultColors];
    }
    BOOL isStack = [dict objectForKey:@"stack"];
    if (isStack) {
        self.chartType = BarChartTypeStack;
    } else if (self.Datas.count > 1) {
        self.chartType = BarChartTypeGroup;
    } else {
        self.chartType = BarChartTypeSingle;
    }
    self.valueInterval = [[dict objectForKey:@"valueInterval"] integerValue];
    if (self.valueInterval == 0) {
        self.valueInterval = 3;
    }
    NSDictionary *styleDict = [dict objectForKey:@"styles"];
    NSDictionary *barStyle = [styleDict objectForKey:@"barStyle"];
    self.minBarWidth = [barStyle objectForKey:@"minBarWidth"] ? [[barStyle objectForKey:@"minBarWidth"] floatValue] : 20;
    self.groupSpace = [barStyle objectForKey:@"groupSpace"] ? [[barStyle objectForKey:@"groupSpace"] floatValue] : 5;
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
    self.gestureScroll.contentSize = CGSizeMake(self.scrollContentSizeWidth, ChartHeight);
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
    _newPinScale = 1.0;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self removeTipView];
    [self redraw];
}

- (void)chartDidZooming:(UIPinchGestureRecognizer *)pinGesture {
    [self removeTipView];
    switch (pinGesture.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint pinCenterContainer = [pinGesture locationInView:self.containerView];
            _pinCenterToLeftDistance = pinCenterContainer.x - LeftEdge;
            CGPoint pinCenterScrollView = [pinGesture locationInView:self.gestureScroll];
            _pinCenterRatio = pinCenterScrollView.x/self.gestureScroll.contentSize.width;
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (pinGesture.scale < 1){
                CGFloat testZoomedWidth = 0;
                if (self.chartType == BarChartTypeGroup) {
                    testZoomedWidth = ([self.Datas count]*self.itemW*self.oldPinScale*pinGesture.scale + self.groupSpace) * [self.Datas[0] count];
                } else {
                    testZoomedWidth = (self.itemW*self.oldPinScale*pinGesture.scale + self.groupSpace) * [self.Datas[0] count];
                }
                if (testZoomedWidth < ChartWidth) {
                    if (self.chartType == BarChartTypeGroup) {
                        _newPinScale = (ChartWidth/[self.Datas[0] count] - self.groupSpace)/self.Datas.count/self.itemW/self.oldPinScale;
                    } else {
                        _newPinScale = (ChartWidth/[self.Datas[0] count] - self.groupSpace)/self.itemW/self.oldPinScale;
                    }
                } else {
                    _newPinScale = pinGesture.scale;
                }
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
- (void)chartDidTapping:(UITapGestureRecognizer *)tapGesture {
    [self removeTipView];
    CGPoint tapP = [tapGesture locationInView:self.gestureScroll];
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(tapP.x, tapP.y, 50, 50)];
    tipView.backgroundColor = [UIColor  redColor];
    tipView.tag = 101;
    [self.gestureScroll addSubview:tipView];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapChart:group:item:)]) {
        NSUInteger group = 0, item = 0;
        if (self.chartType == BarChartTypeGroup) {
            group = floorf(tapP.x / (self.Datas.count * self.zoomedItemW + self.groupSpace));
            item =
            floorf((tapP.x - group * (self.Datas.count * self.zoomedItemW + self.groupSpace)) / self.zoomedItemW);
            if (item > self.Datas.count - 1) {
                item = self.Datas.count - 1;
            }
        } else if (self.chartType == BarChartTypeSingle) {
            group = floorf(tapP.x / (self.zoomedItemW + self.groupSpace));
            item = 0;
        } else { // BarChartTypeStack
            group = floorf(tapP.x / (self.zoomedItemW + self.groupSpace));
            CGFloat zeroY = _dataPostiveSegmentNum * self.yAxisUnitH;
            CGFloat tempY = zeroY;
            for (NSUInteger i = 0; i < self.Datas.count; i++) {
                CGFloat h = [[self.Datas[i] objectAtIndex:group] floatValue] * self.dataItemUnitH;
                if (tapP.y > zeroY) {
                    if (h < 0) {
                        if (tapP.y <= (tempY - h) || i == self.Datas.count - 1) {
                            item = i;
                            break;
                        } else {
                            tempY -= h;
                        }
                    }
                } else {
                    if (h >= 0) {
                        if (tapP.y >= (tempY - h) || i == self.Datas.count - 1) {
                            item = i;
                            break;
                        } else {
                            tempY -= h;
                        }
                    }
                }
            }
        }
        [self.delegate didTapChart:self group:group item:item];
    }
}
- (void)removeTipView {
    UIView *existedV = [self.gestureScroll viewWithTag:101];
    [existedV removeFromSuperview];
}
- (void)adjustScroll {
    self.gestureScroll.contentSize = CGSizeMake(self.scrollContentSizeWidth, ChartHeight);
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
- (void)redraw {
    [_containerView removeFromSuperview];
    _containerView = nil;
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    _containerView.backgroundColor = [UIColor clearColor];
    
    [self insertSubview:_containerView belowSubview:_gestureScroll];
    [self findBeginAndEndIndex];
    [self calculateMaxAndMinValue];
    [self calculateYAxisSegment];
    [self drawYValuePoint];
    [self addXAxisLayer];
    [self addXScaleLayer];
    [self addYAxisLayer];
    [self addYScaleLayer];
}

- (void)findBeginAndEndIndex {
    CGPoint offset = self.gestureScroll.contentOffset;
    if (self.chartType == BarChartTypeGroup) {
        self.beginGroupIndex = floor(offset.x/(self.zoomedItemW*self.Datas.count + self.groupSpace));
        CGFloat itemBeginOffsetX = offset.x - self.beginGroupIndex * (self.zoomedItemW*self.Datas.count + self.groupSpace);
        if (floor(itemBeginOffsetX/self.zoomedItemW) < self.Datas.count) {
            self.beginItemIndex = floor(itemBeginOffsetX/self.zoomedItemW);
        } else {
            self.beginItemIndex = self.Datas.count - 1;
        }
        
        self.endGroupIndex = floor((offset.x+ChartWidth)/(self.zoomedItemW*self.Datas.count + self.groupSpace));
        if (self.endGroupIndex >= [self.Datas[0] count]) {
            self.endGroupIndex = [self.Datas[0] count] - 1;
        }
        CGFloat itemEndOffsetX = offset.x+ChartWidth - self.endGroupIndex * (self.zoomedItemW*self.Datas.count + self.groupSpace);
        if (floor(itemEndOffsetX/self.zoomedItemW) < self.Datas.count) {
            self.endItemIndex = floor(itemEndOffsetX/self.zoomedItemW);
        } else {
            self.endItemIndex = self.Datas.count - 1;
        }
    } else {
        self.beginGroupIndex = floor(offset.x/(self.zoomedItemW + self.groupSpace));
        self.endGroupIndex = floor((offset.x+ChartWidth)/(self.zoomedItemW + self.groupSpace));
    }
    
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

- (void)calculateMaxAndMinValue {
    switch (self.chartType) {
        case BarChartTypeSingle: {
            if (self.beginGroupIndex == self.endGroupIndex) {
                self.minDataValue = [[(NSArray *)self.Datas[0] objectAtIndex:self.beginGroupIndex] floatValue];
                self.maxDataValue = self.minDataValue;
            } else {
                NSMutableArray *array = [NSMutableArray arrayWithCapacity:(self.endGroupIndex - self.beginGroupIndex + 1)];
                for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
                    [array addObject:[(NSArray *)self.Datas[0] objectAtIndex:i]];
                }
                self.minDataValue = [array[0] floatValue];
                self.maxDataValue = self.minDataValue;
                [self findMaxAndMinValue:0 rightIndex:array.count-1 compareA:array];
            }
        }
            break;
        case BarChartTypeStack: {
            if (self.beginGroupIndex == self.endGroupIndex) {
                self.minDataValue = 0; self.maxDataValue = 0;
                for (NSUInteger i=0; i<self.Datas.count; i++) {
                    CGFloat y = [[self.Datas[i] objectAtIndex:self.beginGroupIndex] floatValue];
                    if (y < 0) {
                        self.minDataValue += y;
                    } else {
                        self.maxDataValue += y;
                    }
                    
                }
            } else {
                NSMutableArray *minDataValues = [NSMutableArray arrayWithCapacity:(self.endGroupIndex - self.beginGroupIndex + 1)];
                NSMutableArray *maxDataValues = [NSMutableArray arrayWithCapacity:(self.endGroupIndex - self.beginGroupIndex + 1)];

                for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
                    CGFloat tempMinYValue = 0, tempMaxYValue = 0;
                    for (NSUInteger j=0;j<self.Datas.count;j++) {
                        CGFloat y = [[self.Datas[j] objectAtIndex:i] floatValue];
                        if (y < 0) {
                            tempMinYValue += y;
                        } else {
                            tempMaxYValue += y;
                        }
                    }
                    [minDataValues addObject:[NSString stringWithFormat:@"%f",tempMinYValue]];
                    [maxDataValues addObject:[NSString stringWithFormat:@"%f",tempMaxYValue]];
                }
                self.minDataValue = [minDataValues[0] floatValue];
                self.maxDataValue = [maxDataValues[0] floatValue];
                for (NSString *value in minDataValues) {
                    self.minDataValue = MIN(self.minDataValue, [value floatValue]);
                }
                for (NSString *value in maxDataValues) {
                    self.maxDataValue = MAX(self.maxDataValue, [value floatValue]);
                }
            }
        }
            break;
        case BarChartTypeGroup: {
            if (self.beginGroupIndex == self.endGroupIndex) {
                if (self.beginItemIndex > self.endItemIndex) {
                    self.beginItemIndex = self.endItemIndex;
                }
                self.minDataValue = [[self.Datas[self.beginItemIndex] objectAtIndex:self.beginGroupIndex] floatValue];
                self.maxDataValue = self.minDataValue;
                for (NSUInteger i=self.beginItemIndex+1; i<=self.endItemIndex; i++) {
                    CGFloat tempValue = [[self.Datas[i] objectAtIndex:self.beginGroupIndex] floatValue];
                    self.minDataValue = MIN(self.minDataValue, tempValue);
                    self.maxDataValue = MAX(self.maxDataValue, tempValue);
                }
            } else if (self.beginGroupIndex == self.endGroupIndex - 1) {
                self.minDataValue = [[self.Datas[self.beginItemIndex] objectAtIndex:self.beginGroupIndex] floatValue];
                self.maxDataValue = self.minDataValue;
                
                [self compareBeginAndEndItemValue:self.beginItemIndex+1 endItem:self.Datas.count-1 isBeginGroup:YES];
                [self compareBeginAndEndItemValue:0 endItem:self.endItemIndex isBeginGroup:NO];
            } else {
                self.minDataValue = [[self.Datas[self.beginItemIndex] objectAtIndex:self.beginGroupIndex] floatValue];
                self.maxDataValue = self.minDataValue;
                
                [self compareBeginAndEndItemValue:self.beginItemIndex+1 endItem:self.Datas.count-1 isBeginGroup:YES];
                [self compareBeginAndEndItemValue:0 endItem:self.endItemIndex isBeginGroup:NO];
                [self campareMaxAndMinValue:self.beginGroupIndex+1 rightIndex:self.endGroupIndex-1];

            }
        }
            break;
            
        default:
            break;
    }
}
- (void)compareBeginAndEndItemValue:(NSUInteger)beginItem endItem:(NSUInteger)endItem isBeginGroup:(BOOL)isBeginGroup {
    for (NSUInteger i=beginItem; i<=endItem; i++) {
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

- (void)calculateYAxisSegment {
    if (self.minDataValue >= 0) {
        self.dataPostiveSegmentNum = self.valueInterval;
        if(self.maxDataValue < 1) {
            self.dataPostiveSegmentNum = 1;
        }
        self.dataNegativeSegmentNum = 0;
        self.itemH = ceil([self absoluteMaxValue:self.maxDataValue]/self.dataPostiveSegmentNum);
    } else if (self.maxDataValue < 0) {
        self.dataPostiveSegmentNum = 0;
        self.dataNegativeSegmentNum = self.valueInterval;
        if(fabs(self.minDataValue) < 1) {
            self.dataNegativeSegmentNum = 1;
        }
        self.itemH = ceil([self absoluteMaxValue:self.minDataValue]/self.dataNegativeSegmentNum);
    } else if (self.maxDataValue >= fabs(self.minDataValue)) {
        self.dataPostiveSegmentNum = self.valueInterval;
        if(self.maxDataValue < 1) {
            self.dataPostiveSegmentNum = 1;
        }
        self.itemH = ceil([self absoluteMaxValue:self.maxDataValue]/self.dataPostiveSegmentNum);
        self.dataNegativeSegmentNum = ceil(fabs(self.minDataValue)/self.itemH);
    } else {
        self.dataNegativeSegmentNum = self.valueInterval;
        if(fabs(self.minDataValue) < 1) {
            self.dataNegativeSegmentNum = 1;
        }
        self.itemH = ceil([self absoluteMaxValue:self.minDataValue]/self.dataNegativeSegmentNum);
        self.dataPostiveSegmentNum = ceil(self.maxDataValue/self.itemH);
    }
    self.dataItemUnitH = ChartHeight/(self.itemH * (self.dataPostiveSegmentNum+self.dataNegativeSegmentNum));
}
- (NSUInteger)absoluteMaxValue:(CGFloat)value {
    CGFloat maxNum = fabs(value);
    NSString *str = [NSString stringWithFormat:@"%.0f",floorf(maxNum)];
    NSUInteger tenCube = 1;
    if (str.length > 2) {
        tenCube = pow(10, str.length - 2);
    }
    return ceil(ceil(maxNum / tenCube) / self.valueInterval) * self.valueInterval * tenCube;
}
- (void)drawYValuePoint {
    UIView *subContainerV = [[UIView alloc] initWithFrame:CGRectMake(LeftEdge, TopEdge, ChartWidth, ChartHeight)];
    subContainerV.layer.masksToBounds = YES;
    [self.containerView addSubview:subContainerV];
    switch (self.chartType) {
        case BarChartTypeSingle: {
            NSArray *array = self.Datas[0];
            CGFloat offsetX = self.gestureScroll.contentOffset.x;
            CGFloat zeroY = _dataPostiveSegmentNum * self.yAxisUnitH;
            for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
                CAShapeLayer *yValueLayer = [CAShapeLayer layer];
                CGFloat yPoint = zeroY - [array[i] floatValue] * _dataItemUnitH;
                if ([array[i] floatValue] < 0) {
                    yPoint = zeroY;
                }
                UIBezierPath *yValueBezier = [UIBezierPath bezierPathWithRect:CGRectMake(i*(self.zoomedItemW+self.groupSpace)-offsetX, yPoint, self.zoomedItemW, fabs([array[i] floatValue]) * _dataItemUnitH)];
                yValueLayer.path = yValueBezier.CGPath;
                yValueLayer.lineWidth = 1;
                yValueLayer.strokeColor = [self.barColors[0] CGColor];
                yValueLayer.fillColor = [self.barColors[0] CGColor];
                [subContainerV.layer addSublayer:yValueLayer];
            }
        }
            break;
        case BarChartTypeStack: {
            CGFloat offsetX = self.gestureScroll.contentOffset.x;
            CGFloat zeroY = _dataPostiveSegmentNum * self.yAxisUnitH;
            for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
                CGFloat positiveY = zeroY, negativeY = zeroY, yPoint = zeroY;
                for (NSUInteger j=0; j<self.Datas.count; j++) {
                    NSArray *array = self.Datas[j];
                    CAShapeLayer *yValueLayer = [CAShapeLayer layer];
                    if ([array[i] floatValue] >= 0) {
                        positiveY -= [array[i] floatValue] * _dataItemUnitH;
                        yPoint = positiveY;
                    }
                    if ([array[i] floatValue] < 0 && 0 <= yPoint && yPoint < zeroY) {
                        yPoint = zeroY;
                    }
                    UIBezierPath *yValueBezier = [UIBezierPath bezierPathWithRect:CGRectMake(i*(self.zoomedItemW+self.groupSpace)-offsetX, yPoint, self.zoomedItemW, fabs([array[i] floatValue]) * _dataItemUnitH)];
                    yValueLayer.path = yValueBezier.CGPath;
                    yValueLayer.lineWidth = 1;
                    yValueLayer.strokeColor = [[UIColor hexChangeFloat:self.barColors[j]] CGColor];
                    yValueLayer.fillColor = [[UIColor hexChangeFloat:self.barColors[j]] CGColor];
                    [subContainerV.layer addSublayer:yValueLayer];
                    
                    if ([array[i] floatValue] < 0) {
                        negativeY -= [array[i] floatValue] * _dataItemUnitH;
                        yPoint = negativeY;
                    }
                }
            }
        }
            break;
        case BarChartTypeGroup: {
            CGFloat offsetX = self.gestureScroll.contentOffset.x;
            CGFloat zeroY = _dataPostiveSegmentNum * self.yAxisUnitH;
            if (self.beginItemIndex >= self.Datas.count) break;
            NSUInteger rightLoopIndex = self.endItemIndex;
            if (self.endItemIndex >= self.Datas.count) {
                rightLoopIndex = self.Datas.count - 1;
            }
            if (self.beginGroupIndex == self.endGroupIndex) {
                if (self.beginItemIndex>self.endItemIndex) break;
                [self drawBeginAndEndItemLayer:self.beginItemIndex rightIndex:rightLoopIndex isBegin:YES containerView:subContainerV];
                break;
            }
            
            [self drawBeginAndEndItemLayer:self.beginItemIndex rightIndex:self.Datas.count-1 isBegin:YES containerView:subContainerV];
            [self drawBeginAndEndItemLayer:0 rightIndex:rightLoopIndex isBegin:NO containerView:subContainerV];
            
            for (NSUInteger i=self.beginGroupIndex+1; i<self.endGroupIndex; i++) {
                for (NSUInteger j=0; j<self.Datas.count; j++) {
                    NSArray *array = self.Datas[j];
                    CAShapeLayer *yValueLayer = [CAShapeLayer layer];
                    CGFloat yPoint = zeroY - [array[i] floatValue] * _dataItemUnitH;
                    if ([array[i] floatValue] < 0) {
                        yPoint = zeroY;
                    }
                    UIBezierPath *yValueBezier = [UIBezierPath bezierPathWithRect:CGRectMake(i*(self.zoomedItemW*self.Datas.count+self.groupSpace)+j*self.zoomedItemW-offsetX, yPoint, self.zoomedItemW, fabs([array[i] floatValue]) * _dataItemUnitH)];
                    yValueLayer.path = yValueBezier.CGPath;
                    yValueLayer.lineWidth = 1;
                    yValueLayer.strokeColor = [[UIColor hexChangeFloat:self.barColors[j]] CGColor];
                    yValueLayer.fillColor = [[UIColor hexChangeFloat:self.barColors[j]] CGColor];
                    [subContainerV.layer addSublayer:yValueLayer];
                }
            }
        }
            break;
            
        default:
            break;
    }
}
- (void)drawBeginAndEndItemLayer:(NSInteger)leftIndex rightIndex:(NSInteger)rightIndex isBegin:(BOOL)isBegin containerView:(UIView *)subContainerV {
    CGFloat zeroY = _dataPostiveSegmentNum * self.yAxisUnitH;
    CGFloat offsetX = self.gestureScroll.contentOffset.x;
    
    for (NSUInteger i=leftIndex; i<=rightIndex; i++) {
        NSArray *array = self.Datas[i];
        CAShapeLayer *yValueLayer = [CAShapeLayer layer];
        CGFloat itemValue = isBegin ? [array[self.beginGroupIndex] floatValue] :  [array[self.endGroupIndex] floatValue];
        CGFloat yPoint = zeroY - itemValue * _dataItemUnitH;
        if (itemValue < 0) {
            yPoint = zeroY;
        }
        NSUInteger leftIndex = isBegin ? self.beginGroupIndex : self.endGroupIndex;
        CGFloat x = leftIndex *(self.zoomedItemW*self.Datas.count+self.groupSpace)+i*self.zoomedItemW-offsetX;
        UIBezierPath *yValueBezier = [UIBezierPath bezierPathWithRect:CGRectMake(x, yPoint, self.zoomedItemW, fabs(itemValue) * _dataItemUnitH)];
        yValueLayer.path = yValueBezier.CGPath;
        yValueLayer.lineWidth = 1;
        yValueLayer.strokeColor = [[UIColor hexChangeFloat:self.barColors[i]] CGColor];
        yValueLayer.fillColor = [[UIColor hexChangeFloat:self.barColors[i]] CGColor];
        [subContainerV.layer addSublayer:yValueLayer];
    }
}

- (void)addXAxisLayer {
    CGFloat offsetX = self.gestureScroll.contentOffset.x;
    for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
        CGRect textFrame;
        if (self.chartType == BarChartTypeGroup) {
            if ((self.Datas.count*self.zoomedItemW+self.groupSpace)*(i+0.5) - offsetX < 0) continue;
            textFrame = CGRectMake(LeftEdge+(self.Datas.count*self.zoomedItemW+self.groupSpace)*i - offsetX, self.bounds.size.height - TextHeight, self.Datas.count*self.zoomedItemW, TextHeight);
        } else {
            if ((self.zoomedItemW+self.groupSpace)*(i+0.5) - offsetX < 0) continue;
            textFrame = CGRectMake(LeftEdge+(self.zoomedItemW+self.groupSpace)*i - offsetX, self.bounds.size.height - TextHeight, self.zoomedItemW, TextHeight);
        }
        CATextLayer *text = [self getTextLayerWithString:self.AxisArray[i] textColor:[UIColor blackColor] fontSize:12 backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentRight];
        text.anchorPoint = CGPointMake(1, 1);
        text.transform = CATransform3DMakeRotation(-M_PI_4/2,0,0,1);

        [self.containerView.layer addSublayer:text];
    }
}
- (void)addXScaleLayer {
    CAShapeLayer *xScaleLayer = [CAShapeLayer layer];
    UIBezierPath *xScaleBezier = [UIBezierPath bezierPath];
    [xScaleBezier moveToPoint:CGPointMake(LeftEdge, self.bounds.size.height-BottomEdge)];
    [xScaleBezier addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height-BottomEdge)];
    xScaleLayer.path = xScaleBezier.CGPath;
    xScaleLayer.lineWidth = 1;
    xScaleLayer.strokeColor = [UIColor blackColor].CGColor;
    xScaleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.containerView.layer addSublayer:xScaleLayer];
}
- (void)addYAxisLayer {
    for (NSUInteger i=0; i<_dataNegativeSegmentNum; i++) {
        CGRect textFrame = CGRectMake(0, self.bounds.size.height-1.5*BottomEdge-i*self.yAxisUnitH, TextWidth, BottomEdge);
        NSString *str = [NSString stringWithFormat:@"-%@",[self adjustScaleValue:(_dataNegativeSegmentNum-i)*_itemH]];
        CATextLayer *text = [self getTextLayerWithString:str textColor:[UIColor blackColor] fontSize:12 backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentRight];
        [self.containerView.layer addSublayer:text];
    }
    for (NSInteger i=0; i<=_dataPostiveSegmentNum; i++) {
        CGRect textFrame = CGRectMake(0, self.bounds.size.height-1.5*BottomEdge-(_dataNegativeSegmentNum+i)*self.yAxisUnitH, TextWidth, BottomEdge);
        NSString *str = [NSString stringWithFormat:@"%@",[self adjustScaleValue:i*_itemH]];
        CATextLayer *text = [self getTextLayerWithString:str textColor:[UIColor blackColor] fontSize:12 backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentRight];
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
- (void)addYScaleLayer {
    CAShapeLayer *yScaleLayer = [CAShapeLayer layer];
    UIBezierPath *yScaleBezier = [UIBezierPath bezierPath];
    [yScaleBezier moveToPoint:CGPointMake(LeftEdge+1, TopEdge)];
    [yScaleBezier addLineToPoint:CGPointMake(LeftEdge+1, self.bounds.size.height-BottomEdge)];
    
    for (NSUInteger i=0; i<=_dataNegativeSegmentNum+_dataPostiveSegmentNum+1; i++) {
        [yScaleBezier moveToPoint:CGPointMake(LeftEdge-5, TopEdge+i*self.yAxisUnitH)];
        [yScaleBezier addLineToPoint:CGPointMake(LeftEdge+1, TopEdge+i*self.yAxisUnitH)];
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
        for (NSUInteger i=0; i<=_dataNegativeSegmentNum+_dataPostiveSegmentNum; i++) {
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
    //设置分辨率
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    return textLayer;
}

- (CGFloat)itemW {
    if (_itemW == 0) {
        if (self.chartType == BarChartTypeGroup) {
            CGFloat w = (ChartWidth-[self.Datas[0] count]*self.groupSpace)/[self.Datas[0] count]/self.Datas.count;
            _itemW = w > self.minBarWidth ? w : self.minBarWidth;
        } else {
            _itemW = (ChartWidth/[self.Datas[0] count] - self.groupSpace) > self.minBarWidth ? (ChartWidth/[self.Datas[0] count] - self.groupSpace) : self.minBarWidth;
        }
    }
    return _itemW;
}
- (CGFloat)zoomedItemW {
    return self.itemW * self.newPinScale * self.oldPinScale;
}
- (CGFloat)yAxisUnitH {
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
    self.barColors = [tempColors copy];
}
- (CGFloat)scrollContentSizeWidth {
    if (self.chartType == BarChartTypeGroup) {
        return (self.Datas.count*self.zoomedItemW + self.groupSpace) * [self.Datas[0] count];
    }
    return (self.zoomedItemW + self.groupSpace) * [self.Datas[0] count];
}

@end
