//
//  VerticalBarChartView.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/1/31.
//  Copyright © 2018年 杨虎. All rights reserved.
//
static const float TopEdge = 10;
static const float LeftEdge = 50;
static const float RightEdge = 10;
static const float BottomEdge = 20;
static const float minItemHeight = 20;
static const float TextHeight = 15;
static const float GroupSpace = 5;
#define ChartWidth (self.bounds.size.width-LeftEdge-RightEdge)
#define ChartHeight (self.bounds.size.height-TopEdge-BottomEdge)

#import "VerticalBarChartView.h"

@interface VerticalBarChartView()<UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *gestureScroll;
@property (nonatomic, strong) NSMutableArray *yAxisArray;

@property (nonatomic, assign) NSInteger beginItemIndex;
@property (nonatomic, assign) NSInteger endItemIndex;
@property (nonatomic, assign) CGFloat itemW;
@property (nonatomic, assign) CGFloat itemH;
@property (nonatomic, assign) CGFloat maxXValue;
@property (nonatomic, assign) CGFloat minXValue;

@property (nonatomic, assign) NSUInteger xPostiveSegmentNum;
@property (nonatomic, assign) NSUInteger xNegativeSegmentNum;

@property (nonatomic, assign) CGFloat yItemUnitH;
@property (nonatomic, assign) CGFloat xItemUnitW;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, assign) CGFloat oldPinScale;
@property (nonatomic, assign) CGFloat newPinScale;
@property (nonatomic, assign) CGFloat pinCenterToTopDistance;
@property (nonatomic, assign) CGFloat pinCenterRatio;
@property (nonatomic, assign) CGFloat zoomedItemH;
@property (nonatomic, strong) NSArray *xValues;
@property (nonatomic, strong) NSArray *lineColors;

@property (nonatomic, assign) CGFloat scrollContentSizeHeight;
@property (nonatomic, assign) NSInteger beginGroupIndex;
@property (nonatomic, assign) NSInteger endGroupIndex;

@end

@implementation VerticalBarChartView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addGestureScroll];
    self.chartType = BarChartTypeGroup;
    self.gestureScroll.contentSize = CGSizeMake(ChartWidth, self.scrollContentSizeHeight);
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
            _pinCenterToTopDistance = pinCenterContainer.x - TopEdge;
            CGPoint pinCenterScrollView = [pinGesture locationInView:self.gestureScroll];
            _pinCenterRatio = pinCenterScrollView.y/self.gestureScroll.contentSize.height;
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (pinGesture.scale < 1){
                CGFloat testZoomedHeight = 0;
                if (self.chartType == BarChartTypeGroup) {
                    testZoomedHeight = ([self.xValues count]*self.itemH*self.oldPinScale*pinGesture.scale + GroupSpace) * [self.xValues[0] count];
                } else {
                    testZoomedHeight = (self.itemH*self.oldPinScale*pinGesture.scale + GroupSpace) * [self.xValues[0] count];
                }
                if (testZoomedHeight < ChartHeight) {
                    if (self.chartType == BarChartTypeGroup) {
                        _newPinScale = (ChartHeight/[self.xValues[0] count] - GroupSpace)/self.xValues.count/self.itemH/self.oldPinScale;
                    } else {
                        _newPinScale = (ChartHeight/[self.xValues[0] count] - GroupSpace)/self.itemH/self.oldPinScale;
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
- (void)adjustScroll {
    self.gestureScroll.contentSize = CGSizeMake(self.scrollContentSizeHeight, ChartHeight);
    CGFloat offsetY = self.gestureScroll.contentSize.width * self.pinCenterRatio - self.pinCenterToTopDistance;
    if (offsetY < 0) {
        offsetY = 0;
    }
    if (self.gestureScroll.contentSize.width > ChartWidth) {
        if (offsetY > self.gestureScroll.contentSize.width - ChartWidth) {
            offsetY = self.gestureScroll.contentSize.width - ChartWidth;
        }
    } else {
        offsetY = 0;
    }
    self.gestureScroll.contentOffset = CGPointMake(offsetY, 0);
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
    _containerView.backgroundColor = [UIColor clearColor];
    
    [self insertSubview:_containerView belowSubview:_gestureScroll];
    [self findBeginAndEndIndex];
    [self calculateMaxAndMinValue];
    [self calculateXAxisSegment];
    [self drawXValuePoint];
    [self addXAxisLayer];
    [self addXScaleLayer];
    [self addYAxisLayer];
    [self addYScaleLayer];
}

- (void)findBeginAndEndIndex {
    CGPoint offset = self.gestureScroll.contentOffset;
    if (self.chartType == BarChartTypeGroup) {
        self.beginGroupIndex = floor(offset.y/(self.zoomedItemH*self.xValues.count + GroupSpace));
        CGFloat itemBeginOffsetY = offset.y - self.beginGroupIndex * (self.zoomedItemH*self.xValues.count + GroupSpace);
        if (floor(itemBeginOffsetY/self.zoomedItemH) < self.xValues.count) {
            self.beginItemIndex = floor(itemBeginOffsetY/self.zoomedItemH);
        } else {
            self.beginItemIndex = self.xValues.count - 1;
        }
        
        self.endGroupIndex = floor((offset.y+ChartHeight)/(self.zoomedItemH*self.xValues.count + GroupSpace));
        if (self.endGroupIndex >= [self.xValues[0] count]) {
            self.endGroupIndex = [self.xValues[0] count] - 1;
        }
        CGFloat itemEndOffsetY = offset.y+ChartHeight - self.endGroupIndex * (self.zoomedItemH*self.xValues.count + GroupSpace);
        if (floor(itemEndOffsetY/self.zoomedItemH) < self.xValues.count) {
            self.endItemIndex = floor(itemEndOffsetY/self.zoomedItemH);
        } else {
            self.endItemIndex = self.xValues.count - 1;
        }
    } else {
        self.beginGroupIndex = floor(offset.y/(self.zoomedItemH + GroupSpace));
        self.endGroupIndex = floor((offset.y+ChartHeight)/(self.zoomedItemH + GroupSpace));
    }
    
    if (self.beginGroupIndex < 0) {
        self.beginGroupIndex = 0;
    }
    if (self.beginItemIndex < 0) {
        self.beginItemIndex = 0;
    }
    if (self.beginItemIndex > self.xValues.count) {
        self.beginItemIndex = self.xValues.count - 1;
    }
    if (self.endItemIndex < 0) {
        self.endItemIndex = 0;
    }
    if (self.endItemIndex > self.xValues.count) {
        self.endItemIndex = self.xValues.count - 1;
    }
    
    if (self.endGroupIndex > [self.xValues[0] count] - 1) {
        self.endGroupIndex = [self.xValues[0] count] - 1;
    }
    if (self.beginGroupIndex > self.endGroupIndex) {
        self.beginGroupIndex = self.endGroupIndex;
    }
}

- (void)calculateMaxAndMinValue {
    switch (self.chartType) {
        case BarChartTypeSingle: {
            if (self.beginGroupIndex == self.endGroupIndex) {
                self.minXValue = [[(NSArray *)self.xValues[0] objectAtIndex:self.beginGroupIndex] floatValue];
                self.maxXValue = self.minXValue;
            } else {
                NSMutableArray *array = [NSMutableArray arrayWithCapacity:(self.endGroupIndex - self.beginGroupIndex + 1)];
                for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
                    [array addObject:[(NSArray *)self.xValues[0] objectAtIndex:i]];
                }
                self.minXValue = [array[0] floatValue];
                self.maxXValue = self.minXValue;
                [self findMaxAndMinValue:0 rightIndex:array.count-1 compareA:array];
            }
        }
            break;
        case BarChartTypeStack: {
            if (self.beginGroupIndex == self.endGroupIndex) {
                self.minXValue = 0; self.maxXValue = 0;
                for (NSUInteger i=0; i<self.xValues.count; i++) {
                    CGFloat x = [[self.xValues[i] objectAtIndex:self.beginGroupIndex] floatValue];
                    if (x < 0) {
                        self.minXValue += x;
                    } else {
                        self.maxXValue += x;
                    }
                    
                }
            } else {
                NSMutableArray *minXValues = [NSMutableArray arrayWithCapacity:(self.endGroupIndex - self.beginGroupIndex + 1)];
                NSMutableArray *maxXValues = [NSMutableArray arrayWithCapacity:(self.endGroupIndex - self.beginGroupIndex + 1)];
                
                for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
                    CGFloat tempMinXValue = 0, tempMaxXValue = 0;
                    for (NSUInteger j=0;j<self.xValues.count;j++) {
                        CGFloat x = [[self.xValues[j] objectAtIndex:i] floatValue];
                        if (x< 0) {
                            tempMinXValue += x;
                        } else {
                            tempMaxXValue += x;
                        }
                    }
                    [minXValues addObject:[NSString stringWithFormat:@"%f",tempMinXValue]];
                    [maxXValues addObject:[NSString stringWithFormat:@"%f",tempMaxXValue]];
                }
                self.minXValue = [minXValues[0] floatValue];
                self.maxXValue = [maxXValues[0] floatValue];
                for (NSString *value in minXValues) {
                    self.minXValue = MIN(self.minXValue, [value floatValue]);
                }
                for (NSString *value in maxXValues) {
                    self.maxXValue = MAX(self.maxXValue, [value floatValue]);
                }
            }
        }
            break;
        case BarChartTypeGroup: {
            if (self.beginGroupIndex == self.endGroupIndex) {
                if (self.beginItemIndex > self.endItemIndex) {
                    self.beginItemIndex = self.endItemIndex;
                }
                self.minXValue = [[self.xValues[self.beginItemIndex] objectAtIndex:self.beginGroupIndex] floatValue];
                self.maxXValue = self.minXValue;
                for (NSUInteger i=self.beginItemIndex+1; i<=self.endItemIndex; i++) {
                    CGFloat tempValue = [[self.xValues[i] objectAtIndex:self.beginGroupIndex] floatValue];
                    self.minXValue = MIN(self.minXValue, tempValue);
                    self.maxXValue = MAX(self.maxXValue, tempValue);
                }
            } else if (self.beginGroupIndex == self.endGroupIndex - 1) {
                self.minXValue = [[self.xValues[self.beginItemIndex] objectAtIndex:self.beginGroupIndex] floatValue];
                self.maxXValue = self.minXValue;
                
                [self compareBeginAndEndItemValue:self.beginItemIndex+1 endItem:self.xValues.count-1 isBeginGroup:YES];
                [self compareBeginAndEndItemValue:0 endItem:self.endItemIndex isBeginGroup:NO];
            } else {
                self.minXValue = [[self.xValues[self.beginItemIndex] objectAtIndex:self.beginGroupIndex] floatValue];
                self.maxXValue = self.minXValue;
                
                [self compareBeginAndEndItemValue:self.beginItemIndex+1 endItem:self.xValues.count-1 isBeginGroup:YES];
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
        CGFloat tempValue = [[self.xValues[i] objectAtIndex:index] floatValue];
        self.minXValue = MIN(self.minXValue, tempValue);
        self.maxXValue = MAX(self.maxXValue, tempValue);
    }
}
- (void)campareMaxAndMinValue:(NSUInteger)leftIndex rightIndex:(NSUInteger)rightIndex {
    for (NSArray *values in self.xValues) {
        [self findMaxAndMinValue:leftIndex rightIndex:rightIndex compareA:values];
    }
}
- (void)findMaxAndMinValue:(NSUInteger)leftIndex rightIndex:(NSUInteger)rightIndex compareA:(NSArray *)compareA {
    if (leftIndex > rightIndex) {
        leftIndex = rightIndex;
    }
    if (leftIndex == rightIndex) {
        self.minXValue = MIN([compareA[leftIndex] floatValue], self.minXValue);
        self.maxXValue = MAX([compareA[leftIndex] floatValue], self.maxXValue);
        return;
    } else if(leftIndex == rightIndex-1) {
        if ([compareA[leftIndex] floatValue] < [compareA[rightIndex] floatValue]) {
            self.minXValue = MIN([compareA[leftIndex] floatValue], self.minXValue);
            self.maxXValue = MAX([compareA[rightIndex] floatValue], self.maxXValue);
            return;
        } else {
            self.minXValue = MIN([compareA[rightIndex] floatValue], self.minXValue);
            self.maxXValue = MAX([compareA[leftIndex] floatValue], self.maxXValue);
            return;
        }
    }
    NSUInteger mid = (leftIndex + rightIndex)/2;
    [self findMaxAndMinValue:leftIndex rightIndex:mid compareA:compareA];
    [self findMaxAndMinValue:mid + 1 rightIndex:rightIndex compareA:compareA];
}

- (void)calculateXAxisSegment {
    if (self.minXValue >= 0) {
        self.xPostiveSegmentNum = 4;
        if(self.maxXValue < 1) {
            self.xPostiveSegmentNum = 1;
        }
        self.xNegativeSegmentNum = 0;
        self.itemW = ceil(self.maxXValue/self.xPostiveSegmentNum);
        self.xItemUnitW = ChartWidth/(self.itemW * self.xPostiveSegmentNum);
    } else if (self.maxXValue < 0) {
        self.xPostiveSegmentNum = 0;
        self.xNegativeSegmentNum = 4;
        if(fabs(self.minXValue) < 1) {
            self.xNegativeSegmentNum = 1;
        }
        self.itemW = ceil(fabs(self.minXValue)/self.xNegativeSegmentNum);
        self.xItemUnitW = ChartWidth/(self.itemW * self.xNegativeSegmentNum);
    } else if (self.maxXValue >= fabs(self.minXValue)) {
        self.xPostiveSegmentNum = 4;
        if(self.maxXValue < 1) {
            self.xPostiveSegmentNum = 1;
        }
        self.itemW = ceil(self.maxXValue/self.xPostiveSegmentNum);
        self.xNegativeSegmentNum = ceil(fabs(self.minXValue)/self.itemW);
        self.xItemUnitW = ChartWidth/(self.itemW * (self.xPostiveSegmentNum+self.xNegativeSegmentNum));
    } else {
        self.xNegativeSegmentNum = 4;
        if(fabs(self.minXValue) < 1) {
            self.xNegativeSegmentNum = 1;
        }
        self.itemW = ceil(fabs(self.minXValue)/self.xNegativeSegmentNum);
        self.xPostiveSegmentNum = ceil(self.maxXValue/self.itemW);
        self.xItemUnitW = ChartWidth/(self.itemW * (self.xPostiveSegmentNum+self.xNegativeSegmentNum));
    }
}

- (void)drawXValuePoint {
    UIView *subContainerV = [[UIView alloc] initWithFrame:CGRectMake(LeftEdge, TopEdge, ChartWidth, ChartHeight)];
    subContainerV.layer.masksToBounds = YES;
    [self.containerView addSubview:subContainerV];
    switch (self.chartType) {
        case BarChartTypeSingle: {
            NSArray *array = self.xValues[0];
            CGFloat offsetY = self.gestureScroll.contentOffset.y;
            CGFloat zeroX = _xNegativeSegmentNum * self.xAxisUnitW;
            for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
                CAShapeLayer *xValueLayer = [CAShapeLayer layer];
                CGFloat xPoint = zeroX;
                if ([array[i] floatValue] < 0) {
                    xPoint = zeroX + [array[i] floatValue] * _xItemUnitW;
                }
                UIBezierPath *xValueBezier = [UIBezierPath bezierPathWithRect:CGRectMake(xPoint, i*(self.zoomedItemH+GroupSpace)-offsetY, fabs([array[i] floatValue]) * _xItemUnitW, self.zoomedItemH)];
                xValueLayer.path = xValueBezier.CGPath;
                xValueLayer.lineWidth = 1;
                xValueLayer.strokeColor = [self.lineColors[0] CGColor];
                xValueLayer.fillColor = [self.lineColors[0] CGColor];
                [subContainerV.layer addSublayer:xValueLayer];
            }
        }
            break;
        case BarChartTypeStack: {
            CGFloat offsetY = self.gestureScroll.contentOffset.y;
            CGFloat zeroX = _xNegativeSegmentNum * self.xAxisUnitW;
            for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
                CGFloat positiveX = zeroX, negativeX = zeroX, xPoint = zeroX;
                for (NSUInteger j=0; j<self.xValues.count; j++) {
                    NSArray *array = self.xValues[j];
                    CAShapeLayer *xValueLayer = [CAShapeLayer layer];
                    if ([array[i] floatValue] < 0) {
                        negativeX += [array[i] floatValue] * _xItemUnitW;
                        xPoint = negativeX;
                    }
                    if ([array[i] floatValue] >= 0 && xPoint < zeroX) {
                        xPoint = zeroX;
                    }
                    UIBezierPath *xValueBezier = [UIBezierPath bezierPathWithRect:CGRectMake(xPoint, i*(self.zoomedItemH+GroupSpace)-offsetY, fabs([array[i] floatValue]) * _xItemUnitW, self.zoomedItemH)];
                    xValueLayer.path = xValueBezier.CGPath;
                    xValueLayer.lineWidth = 1;
                    xValueLayer.strokeColor = [self.lineColors[j] CGColor];
                    xValueLayer.fillColor = [self.lineColors[j] CGColor];
                    [subContainerV.layer addSublayer:xValueLayer];
                    
                    if ([array[i] floatValue] >= 0) {
                        positiveX += [array[i] floatValue] * _xItemUnitW;
                        xPoint = positiveX;
                    }
                }
            }
        }
            break;
        case BarChartTypeGroup: {
            CGFloat offsetY = self.gestureScroll.contentOffset.y;
            CGFloat zeroX = _xNegativeSegmentNum * self.xAxisUnitW;
            if (self.beginItemIndex >= self.xValues.count) break;
            NSUInteger rightLoopIndex = self.endItemIndex;
            if (self.endItemIndex >= self.xValues.count) {
                rightLoopIndex = self.xValues.count - 1;
            }
            if (self.beginGroupIndex == self.endGroupIndex) {
                if (self.beginItemIndex>self.endItemIndex) break;
                [self drawBeginAndEndItemLayer:self.beginItemIndex rightIndex:rightLoopIndex isBegin:YES containerView:subContainerV];
                break;
            }
            
            [self drawBeginAndEndItemLayer:self.beginItemIndex rightIndex:self.xValues.count-1 isBegin:YES containerView:subContainerV];
            [self drawBeginAndEndItemLayer:0 rightIndex:rightLoopIndex isBegin:NO containerView:subContainerV];
            
            for (NSUInteger i=self.beginGroupIndex+1; i<self.endGroupIndex; i++) {
                for (NSUInteger j=0; j<self.xValues.count; j++) {
                    NSArray *array = self.xValues[j];
                    CAShapeLayer *xValueLayer = [CAShapeLayer layer];
                    
                    CGFloat xPoint = zeroX;
                    if ([array[i] floatValue] < 0) {
                        xPoint = zeroX + [array[i] floatValue] * _xItemUnitW;
                    }
                    UIBezierPath *xValueBezier = [UIBezierPath bezierPathWithRect:CGRectMake(xPoint, i*(self.zoomedItemH*self.xValues.count+GroupSpace)+j*self.zoomedItemH-offsetY, fabs([array[i] floatValue]) * _xItemUnitW, self.zoomedItemH)];
                    xValueLayer.path = xValueBezier.CGPath;
                    xValueLayer.lineWidth = 1;
                    xValueLayer.strokeColor = [self.lineColors[j] CGColor];
                    xValueLayer.fillColor = [self.lineColors[j] CGColor];
                    [subContainerV.layer addSublayer:xValueLayer];
                }
            }
        }
            break;
            
        default:
            break;
    }
}
- (void)drawBeginAndEndItemLayer:(NSInteger)leftIndex rightIndex:(NSInteger)rightIndex isBegin:(BOOL)isBegin containerView:(UIView *)subContainerV {
    CGFloat zeroX = _xNegativeSegmentNum * self.xAxisUnitW;
    CGFloat offsetY = self.gestureScroll.contentOffset.y;
    
    for (NSUInteger i=leftIndex; i<=rightIndex; i++) {
        NSArray *array = self.xValues[i];
        CAShapeLayer *xValueLayer = [CAShapeLayer layer];
        CGFloat itemValue = isBegin ? [array[self.beginGroupIndex] floatValue] :  [array[self.endGroupIndex] floatValue];
        CGFloat xPoint = zeroX;
        if (itemValue < 0) {
            xPoint = zeroX + itemValue * _xItemUnitW;
        }
        NSUInteger leftIndex = isBegin ? self.beginGroupIndex : self.endGroupIndex;
        CGFloat y = leftIndex *(self.zoomedItemH*self.xValues.count+GroupSpace)+i*self.zoomedItemH-offsetY;
        UIBezierPath *xValueBezier = [UIBezierPath bezierPathWithRect:CGRectMake(xPoint, y, fabs(itemValue) * _xItemUnitW, self.zoomedItemH)];
        xValueLayer.path = xValueBezier.CGPath;
        xValueLayer.lineWidth = 1;
        xValueLayer.strokeColor = [self.lineColors[i] CGColor];
        xValueLayer.fillColor = [self.lineColors[i] CGColor];
        [subContainerV.layer addSublayer:xValueLayer];
    }
}

- (void)addYAxisLayer {
    CGFloat offsetY = self.gestureScroll.contentOffset.y;
    for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
        CGRect textFrame;
        if (self.chartType == BarChartTypeGroup) {
            if ((self.xValues.count*self.zoomedItemH+GroupSpace)*i - offsetY + (self.xValues.count*self.zoomedItemH-TextHeight)/2.0 < 0) continue;
            textFrame = CGRectMake(0, TopEdge+(self.xValues.count*self.zoomedItemH+GroupSpace)*i - offsetY + (self.xValues.count*self.zoomedItemH-TextHeight)/2.0, LeftEdge, TextHeight);
        } else {
            if ((self.zoomedItemH+GroupSpace)*i - offsetY + (self.zoomedItemH-TextHeight)/2.0 < 0) continue;
            textFrame = CGRectMake(0, TopEdge+(self.zoomedItemH+GroupSpace)*i - offsetY + (self.zoomedItemH-TextHeight)/2.0, LeftEdge, TextHeight);
        }
        CATextLayer *text = [self getTextLayerWithString:self.yAxisArray[i] textColor:[UIColor blackColor] fontSize:12 backgroundColor:[UIColor clearColor] frame:textFrame];
        [self.containerView.layer addSublayer:text];
    }
}
- (void)addYScaleLayer {
    CAShapeLayer *yScaleLayer = [CAShapeLayer layer];
    UIBezierPath *yScaleBezier = [UIBezierPath bezierPath];
    [yScaleBezier moveToPoint:CGPointMake(LeftEdge, TopEdge)];
    [yScaleBezier addLineToPoint:CGPointMake(LeftEdge, self.bounds.size.height-BottomEdge)];
    yScaleLayer.path = yScaleBezier.CGPath;
    yScaleLayer.lineWidth = 1;
    yScaleLayer.strokeColor = [UIColor blackColor].CGColor;
    yScaleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.containerView.layer addSublayer:yScaleLayer];
}
- (void)addXAxisLayer {
    for (NSUInteger i=0; i<_xNegativeSegmentNum; i++) {
        CGRect textFrame = CGRectMake((i-0.5)*self.xAxisUnitW+LeftEdge, self.bounds.size.height-TextHeight, self.xAxisUnitW, TextHeight);
        CATextLayer *text = [self getTextLayerWithString:[NSString stringWithFormat:@"-%.2f",(_xNegativeSegmentNum-i)*_itemW] textColor:[UIColor blackColor] fontSize:12 backgroundColor:[UIColor clearColor] frame:textFrame];
        [self.containerView.layer addSublayer:text];
    }
    for (NSInteger i=0; i<=_xPostiveSegmentNum+1; i++) {
        CGRect textFrame = CGRectMake((_xNegativeSegmentNum+i-0.5)*self.xAxisUnitW+LeftEdge, self.bounds.size.height-TextHeight, self.xAxisUnitW, TextHeight);
        CATextLayer *text = [self getTextLayerWithString:[NSString stringWithFormat:@"%.2f",i*_itemW] textColor:[UIColor blackColor] fontSize:12 backgroundColor:[UIColor clearColor] frame:textFrame];
        [self.containerView.layer addSublayer:text];
    }
}
- (void)addXScaleLayer {
    CAShapeLayer *xScaleLayer = [CAShapeLayer layer];
    UIBezierPath *xScaleBezier = [UIBezierPath bezierPath];
    [xScaleBezier moveToPoint:CGPointMake(LeftEdge, self.bounds.size.height-BottomEdge)];
    [xScaleBezier addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height-BottomEdge)];
    
    for (NSUInteger i=0; i<=_xNegativeSegmentNum+_xPostiveSegmentNum+1; i++) {
        [xScaleBezier moveToPoint:CGPointMake(LeftEdge+i*self.xAxisUnitW, self.bounds.size.height-BottomEdge)];
        [xScaleBezier addLineToPoint:CGPointMake(LeftEdge+i*self.xAxisUnitW, self.bounds.size.height-BottomEdge+5)];
    }
    xScaleLayer.path = xScaleBezier.CGPath;
    xScaleLayer.backgroundColor = [UIColor blueColor].CGColor;
    xScaleLayer.lineWidth = 1;
    xScaleLayer.strokeColor = [UIColor blackColor].CGColor;
    xScaleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.containerView.layer addSublayer:xScaleLayer];
    
    if (YES) {
        CAShapeLayer *dashLineLayer = [CAShapeLayer layer];
        UIBezierPath *dashLineBezier = [UIBezierPath bezierPath];
        for (NSUInteger i=0; i<=_xNegativeSegmentNum+_xPostiveSegmentNum; i++) {
            [dashLineBezier moveToPoint:CGPointMake(LeftEdge+i*self.xAxisUnitW, self.bounds.size.height-BottomEdge)];
            [dashLineBezier addLineToPoint:CGPointMake(LeftEdge+i*self.xAxisUnitW, TopEdge)];
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

- (NSMutableArray *)yAxisArray {
    if (!_yAxisArray) {
        _yAxisArray = [NSMutableArray arrayWithObjects:@"Mon",@"Tues",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun", nil];
    }
    return _yAxisArray;
}

- (NSArray *)xValues {
    if (!_xValues) {
        _xValues = @[
                     @[@"0.1",@"0.2",@"0.3",@"-0.4",@"0.5",@"0.6",@"-0.7"],
                     @[@"0.5",@"0.6",@"-0.7",@"0.9",@"0.12",@"0.13",@"-0.14"]
                     ];
    }
    return _xValues;
}
- (CGFloat)itemH {
    if (_itemH == 0) {
        if (self.chartType == BarChartTypeGroup) {
            CGFloat h = (ChartHeight-[self.xValues[0] count]*GroupSpace)/[self.xValues[0] count]/self.xValues.count;
            _itemH = h > minItemHeight ? h : minItemHeight;
        } else {
            _itemH = (ChartHeight/[self.xValues[0] count] - GroupSpace) > minItemHeight ? (ChartHeight/[self.xValues[0] count] - GroupSpace) : minItemHeight;
        }
    }
    return _itemH;
}
- (CGFloat)zoomedItemH {
    return self.itemH * self.newPinScale * self.oldPinScale;
}
- (CGFloat)xAxisUnitW {
    return ChartWidth/(_xNegativeSegmentNum + _xPostiveSegmentNum);
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
        NSMutableArray *colors = [NSMutableArray arrayWithCapacity:self.xValues.count];
        for (NSUInteger i=0; i<self.xValues.count; i++) {
            UIColor *color = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1];
            [colors addObject:color];
        }
        _lineColors = [colors copy];
    }
    return _lineColors;
}
- (CGFloat)scrollContentSizeHeight {
    if (self.chartType == BarChartTypeGroup) {
        return (self.xValues.count*self.zoomedItemH + GroupSpace) * [self.xValues[0] count];
    }
    return (self.zoomedItemH + GroupSpace) * [self.xValues[0] count];
}

@end
