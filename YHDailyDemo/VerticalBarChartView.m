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
static const float TextHeight = 11;
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

#import "VerticalBarChartView.h"
#import "UIColor+HexColor.h"
#import "NSString+Extra.h"
typedef NS_ENUM(NSUInteger,BarChartType) {
    BarChartTypeSingle = 0,
    BarChartTypeGroup = 1,
    BarChartTypeStack = 2
};

@interface VerticalBarChartView()<UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *gestureScroll;
@property (nonatomic, strong) NSMutableArray<NSString *> *AxisArray;
@property (nonatomic, strong) NSArray<NSArray *> *Datas;

@property (nonatomic, assign) NSInteger beginItemIndex;
@property (nonatomic, assign) NSInteger endItemIndex;
@property (nonatomic, assign) NSUInteger itemDataScale;
@property (nonatomic, assign) CGFloat itemAxisScale;
@property (nonatomic, assign) CGFloat maxDataValue;
@property (nonatomic, assign) CGFloat minDataValue;

@property (nonatomic, assign) NSUInteger dataPostiveSegmentNum;
@property (nonatomic, assign) NSUInteger dataNegativeSegmentNum;

@property (nonatomic, assign) CGFloat dataItemUnitScale;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, assign) CGFloat oldPinScale;
@property (nonatomic, assign) CGFloat newPinScale;
@property (nonatomic, assign) CGFloat pinCenterToTopDistance;
@property (nonatomic, assign) CGFloat pinCenterRatio;
@property (nonatomic, assign) CGFloat zoomedItemAxis;

@property (nonatomic, assign) CGFloat scrollContentSizeHeight;
@property (nonatomic, assign) NSInteger beginGroupIndex;
@property (nonatomic, assign) NSInteger endGroupIndex;

@property (nonatomic, assign) BOOL isDataError;
@property (nonatomic, strong) NSArray *groupMembers;
@property (nonatomic, copy) NSString *axisTitle;
@property (nonatomic, copy) NSString *dataTitle;
@property (nonatomic, strong) NSArray *itemColors;
@property (nonatomic, assign) BarChartType chartType;
@property (nonatomic, assign) NSUInteger valueInterval;
@property (nonatomic, assign) CGFloat minItemWidth;
@property (nonatomic, assign) CGFloat groupSpace;
@property (nonatomic, assign) CGFloat zeroLine;
@property (nonatomic, assign) BOOL showDataDashLine;
@property (nonatomic, assign) BOOL hideDataHardLine;

@end

@implementation VerticalBarChartView
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
    self.minItemWidth = [barStyle objectForKey:@"minItemWidth"] ? [[barStyle objectForKey:@"minItemWidth"] floatValue] : 20;
    self.groupSpace = [barStyle objectForKey:@"groupSpace"] ? [[barStyle objectForKey:@"groupSpace"] floatValue] : 5;
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
                    testZoomedHeight = ([self.Datas count]*self.itemAxisScale*self.oldPinScale*pinGesture.scale + self.groupSpace) * [self.Datas[0] count];
                } else {
                    testZoomedHeight = (self.itemAxisScale*self.oldPinScale*pinGesture.scale + self.groupSpace) * [self.Datas[0] count];
                }
                if (testZoomedHeight < ChartHeight) {
                    if (self.chartType == BarChartTypeGroup) {
                        _newPinScale = (ChartHeight/[self.Datas[0] count] - self.groupSpace)/self.Datas.count/self.itemAxisScale/self.oldPinScale;
                    } else {
                        _newPinScale = (ChartHeight/[self.Datas[0] count] - self.groupSpace)/self.itemAxisScale/self.oldPinScale;
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
            _newPinScale = 1.0;
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
    
    NSUInteger group = 0, item = 0;
    if (self.chartType == BarChartTypeGroup) {
        group = floorf(tapP.y / (self.Datas.count * self.zoomedItemAxis + self.groupSpace));
        item =
        floorf((tapP.y - group * (self.Datas.count * self.zoomedItemAxis + self.groupSpace)) / self.zoomedItemAxis);
        if (item > self.Datas.count - 1) {
            item = self.Datas.count - 1;
        }
    } else if (self.chartType == BarChartTypeSingle) {
        group = floorf(tapP.y / (self.zoomedItemAxis + self.groupSpace));
        item = 0;
    } else { // BarChartTypeStack
        group = floorf(tapP.y / (self.zoomedItemAxis + self.groupSpace));
        CGFloat tempX = self.zeroLine;
        for (NSUInteger i = 0; i < self.Datas.count; i++) {
            CGFloat w = [[self.Datas[i] objectAtIndex:group] floatValue] * self.dataItemUnitScale;
            if (tapP.x < self.zeroLine) {
                if (w < 0) {
                    if (tapP.x >= (tempX + w) || i == self.Datas.count - 1) {
                        item = i;
                        break;
                    } else {
                        tempX += w;
                    }
                }
            } else {
                if (w >= 0) {
                    if (tapP.x <= (tempX + w) || i == self.Datas.count - 1) {
                        item = i;
                        break;
                    } else {
                        tempX += w;
                    }
                }
            }
        }
    }
    CGPoint containerP = [tapGesture locationInView:self.containerView];
    [self updateTipLayer:group item:item containerPoint:containerP];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapChart:group:item:)]) {
        [self.delegate didTapChart:self group:group item:item];
    }
}
- (void)updateTipLayer:(NSUInteger)group item:(NSUInteger)item containerPoint:(CGPoint)point {
    CGPoint tempP = point;
    CGFloat absoluteZeroLine = self.zeroLine + LeftEdge;
    if (self.chartType == BarChartTypeStack) {
        CGFloat tempZeroLine = absoluteZeroLine;
        if (tempP.x < absoluteZeroLine) {
            for (NSUInteger i=0; i<=item; i++) {
                if ([[self.Datas[i] objectAtIndex:group] floatValue] < 0) {
                    tempZeroLine += [[self.Datas[i] objectAtIndex:group] floatValue] * _dataItemUnitScale;
                    if (tempZeroLine <= tempP.x) break;
                }
            }
            if (tempP.x < tempZeroLine) {
                tempP = CGPointMake(tempZeroLine, tempP.y);
            }
        } else {
            for (NSUInteger i=0; i<=item; i++) {
                if ([[self.Datas[i] objectAtIndex:group] floatValue] > 0) {
                    tempZeroLine += [[self.Datas[i] objectAtIndex:group] floatValue] * _dataItemUnitScale;
                    if (tempZeroLine >= tempP.x) break;
                }
            }
            if (tempP.x > tempZeroLine) {
                tempP = CGPointMake(tempZeroLine, tempP.y);
            }
        }
    } else {
        if (tempP.x < absoluteZeroLine) {
            if ([[self.Datas[item] objectAtIndex:group] floatValue] >= 0) {
                tempP = CGPointMake(absoluteZeroLine, tempP.y);
            } else if (tempP.x < (absoluteZeroLine + [[self.Datas[item] objectAtIndex:group] floatValue] * _dataItemUnitScale)) {
                tempP.x = absoluteZeroLine + [[self.Datas[item] objectAtIndex:group] floatValue] * _dataItemUnitScale;
            }
        } else {
            if ([[self.Datas[item] objectAtIndex:group] floatValue] < 0) {
                tempP = CGPointMake(absoluteZeroLine, tempP.y);
            } else if (tempP.x > (absoluteZeroLine + [[self.Datas[item] objectAtIndex:group] floatValue] * _dataItemUnitScale)) {
                tempP.x = absoluteZeroLine + [[self.Datas[item] objectAtIndex:group] floatValue] * _dataItemUnitScale;
            }
        }
    }
    
    NSString *axisStr;
    NSString *dataStr = [NSString stringWithFormat:@"%@: %@",self.dataTitle,[self.Datas[item] objectAtIndex:group]];
    if (self.chartType == BarChartTypeSingle) {
        dataStr = [NSString stringWithFormat:@"%@: %@",self.AxisArray[group],[self.Datas[item] objectAtIndex:group]];
    } else {
        axisStr = [NSString stringWithFormat:@"%@: %@",self.axisTitle,self.AxisArray[group]];
        dataStr = [NSString stringWithFormat:@"%@: %@",self.groupMembers[item],[self.Datas[item] objectAtIndex:group]];
    }
    CGFloat tipTextH = 11;
    CGFloat tipH = 10 + tipTextH + 5;
    CGFloat tipMaxW = [dataStr measureTextWidth:[UIFont systemFontOfSize:9]];
    if (axisStr) {
        tipMaxW = MAX(tipMaxW, [axisStr measureTextWidth:[UIFont systemFontOfSize:9]]);
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
    _containerView.backgroundColor = [UIColor clearColor];
    
    [self insertSubview:_containerView belowSubview:_gestureScroll];
    [self findBeginAndEndIndex];
    [self calculateMaxAndMinValue];
    [self calculateDataSegment];
    [self addDataLayer];
    [self addDataScaleLayer];
    [self addAxisLayer];
    [self addAxisScaleLayer];
    [self drawDataPoint];

}

- (void)findBeginAndEndIndex {
    CGPoint offset = self.gestureScroll.contentOffset;
    if (self.chartType == BarChartTypeGroup) {
        self.beginGroupIndex = floor(offset.y/(self.zoomedItemAxis*self.Datas.count + self.groupSpace));
        CGFloat itemBeginOffsetY = offset.y - self.beginGroupIndex * (self.zoomedItemAxis*self.Datas.count + self.groupSpace);
        if (floor(itemBeginOffsetY/self.zoomedItemAxis) < self.Datas.count) {
            self.beginItemIndex = floor(itemBeginOffsetY/self.zoomedItemAxis);
        } else {
            self.beginItemIndex = self.Datas.count - 1;
        }
        
        self.endGroupIndex = floor((offset.y+ChartHeight)/(self.zoomedItemAxis*self.Datas.count + self.groupSpace));
        if (self.endGroupIndex >= [self.Datas[0] count]) {
            self.endGroupIndex = [self.Datas[0] count] - 1;
        }
        CGFloat itemEndOffsetY = offset.y+ChartHeight - self.endGroupIndex * (self.zoomedItemAxis*self.Datas.count + self.groupSpace);
        if (floor(itemEndOffsetY/self.zoomedItemAxis) < self.Datas.count) {
            self.endItemIndex = floor(itemEndOffsetY/self.zoomedItemAxis);
        } else {
            self.endItemIndex = self.Datas.count - 1;
        }
    } else {
        self.beginGroupIndex = floor(offset.y/(self.zoomedItemAxis + self.groupSpace));
        self.endGroupIndex = floor((offset.y+ChartHeight)/(self.zoomedItemAxis + self.groupSpace));
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
                    CGFloat x = [[self.Datas[i] objectAtIndex:self.beginGroupIndex] floatValue];
                    if (x < 0) {
                        self.minDataValue += x;
                    } else {
                        self.maxDataValue += x;
                    }
                    
                }
            } else {
                NSMutableArray *minDataValues = [NSMutableArray arrayWithCapacity:(self.endGroupIndex - self.beginGroupIndex + 1)];
                NSMutableArray *maxDataValues = [NSMutableArray arrayWithCapacity:(self.endGroupIndex - self.beginGroupIndex + 1)];
                
                for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
                    CGFloat tempMinXValue = 0, tempMaxXValue = 0;
                    for (NSUInteger j=0;j<self.Datas.count;j++) {
                        CGFloat x = [[self.Datas[j] objectAtIndex:i] floatValue];
                        if (x< 0) {
                            tempMinXValue += x;
                        } else {
                            tempMaxXValue += x;
                        }
                    }
                    [minDataValues addObject:[NSString stringWithFormat:@"%f",tempMinXValue]];
                    [maxDataValues addObject:[NSString stringWithFormat:@"%f",tempMaxXValue]];
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

- (void)calculateDataSegment {
    if (self.minDataValue >= 0) {
        self.dataPostiveSegmentNum = self.valueInterval;
        if(self.maxDataValue < 1) {
            self.dataPostiveSegmentNum = 1;
        }
        self.dataNegativeSegmentNum = 0;
        self.itemDataScale = ceil([self absoluteMaxValue:self.maxDataValue]/self.dataPostiveSegmentNum);
    } else if (self.maxDataValue < 0) {
        self.dataPostiveSegmentNum = 0;
        self.dataNegativeSegmentNum = self.valueInterval;
        if(fabs(self.minDataValue) < 1) {
            self.dataNegativeSegmentNum = 1;
        }
        self.itemDataScale = ceil([self absoluteMaxValue:self.minDataValue]/self.dataNegativeSegmentNum);
    } else if (self.maxDataValue >= fabs(self.minDataValue)) {
        self.dataPostiveSegmentNum = self.valueInterval;
        if(self.maxDataValue < 1) {
            self.dataPostiveSegmentNum = 1;
        }
        self.itemDataScale = ceil([self absoluteMaxValue:self.maxDataValue]/self.dataPostiveSegmentNum);
        self.dataNegativeSegmentNum = ceil(fabs(self.minDataValue)/self.itemDataScale);
    } else {
        self.dataNegativeSegmentNum = self.valueInterval;
        if(fabs(self.minDataValue) < 1) {
            self.dataNegativeSegmentNum = 1;
        }
        self.itemDataScale = ceil([self absoluteMaxValue:self.minDataValue]/self.dataNegativeSegmentNum);
        self.dataPostiveSegmentNum = ceil(self.maxDataValue/self.itemDataScale);
    }
    self.dataItemUnitScale = ChartWidth/(self.itemDataScale * (self.dataPostiveSegmentNum+self.dataNegativeSegmentNum));
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
- (void)drawDataPoint {
    UIView *subContainerV = [[UIView alloc] initWithFrame:CGRectMake(LeftEdge, TopEdge, ChartWidth, ChartHeight)];
    subContainerV.layer.masksToBounds = YES;
    [self.containerView addSubview:subContainerV];
    switch (self.chartType) {
        case BarChartTypeSingle: {
            NSArray *array = self.Datas[0];
            CGFloat offsetY = self.gestureScroll.contentOffset.y;
            for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
                CAShapeLayer *xValueLayer = [CAShapeLayer layer];
                CGFloat xPoint = self.zeroLine;
                if ([array[i] floatValue] < 0) {
                    xPoint = self.zeroLine + [array[i] floatValue] * _dataItemUnitScale;
                }
                UIBezierPath *xValueBezier = [UIBezierPath bezierPathWithRect:CGRectMake(xPoint, i*(self.zoomedItemAxis+self.groupSpace)-offsetY, fabs([array[i] floatValue]) * _dataItemUnitScale, self.zoomedItemAxis)];
                xValueLayer.path = xValueBezier.CGPath;
                xValueLayer.lineWidth = 1;
                xValueLayer.strokeColor = [self.itemColors[0] CGColor];
                xValueLayer.fillColor = [self.itemColors[0] CGColor];
                [subContainerV.layer addSublayer:xValueLayer];
            }
        }
            break;
        case BarChartTypeStack: {
            CGFloat offsetY = self.gestureScroll.contentOffset.y;
            for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
                CGFloat positiveX = self.zeroLine, negativeX = self.zeroLine, xPoint = self.zeroLine;
                for (NSUInteger j=0; j<self.Datas.count; j++) {
                    NSArray *array = self.Datas[j];
                    CAShapeLayer *xValueLayer = [CAShapeLayer layer];
                    if ([array[i] floatValue] < 0) {
                        negativeX += [array[i] floatValue] * _dataItemUnitScale;
                        xPoint = negativeX;
                    }
                    if ([array[i] floatValue] >= 0 && xPoint < self.zeroLine) {
                        xPoint = self.zeroLine;
                    }
                    UIBezierPath *xValueBezier = [UIBezierPath bezierPathWithRect:CGRectMake(xPoint, i*(self.zoomedItemAxis+self.groupSpace)-offsetY, fabs([array[i] floatValue]) * _dataItemUnitScale, self.zoomedItemAxis)];
                    xValueLayer.path = xValueBezier.CGPath;
                    xValueLayer.lineWidth = 1;
                    xValueLayer.strokeColor = [[UIColor hexChangeFloat:self.itemColors[j]] CGColor];
                    xValueLayer.fillColor = [[UIColor hexChangeFloat:self.itemColors[j]] CGColor];
                    [subContainerV.layer addSublayer:xValueLayer];
                    
                    if ([array[i] floatValue] >= 0) {
                        positiveX += [array[i] floatValue] * _dataItemUnitScale;
                        xPoint = positiveX;
                    }
                }
            }
        }
            break;
        case BarChartTypeGroup: {
            CGFloat offsetY = self.gestureScroll.contentOffset.y;
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
                    CAShapeLayer *xValueLayer = [CAShapeLayer layer];
                    
                    CGFloat xPoint = self.zeroLine;
                    if ([array[i] floatValue] < 0) {
                        xPoint = self.zeroLine + [array[i] floatValue] * _dataItemUnitScale;
                    }
                    UIBezierPath *xValueBezier = [UIBezierPath bezierPathWithRect:CGRectMake(xPoint, i*(self.zoomedItemAxis*self.Datas.count+self.groupSpace)+j*self.zoomedItemAxis-offsetY, fabs([array[i] floatValue]) * _dataItemUnitScale, self.zoomedItemAxis)];
                    xValueLayer.path = xValueBezier.CGPath;
                    xValueLayer.lineWidth = 1;
                    xValueLayer.strokeColor = [[UIColor hexChangeFloat:self.itemColors[j]] CGColor];
                    xValueLayer.fillColor = [[UIColor hexChangeFloat:self.itemColors[j]] CGColor];
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
    CGFloat offsetY = self.gestureScroll.contentOffset.y;
    
    for (NSUInteger i=leftIndex; i<=rightIndex; i++) {
        NSArray *array = self.Datas[i];
        CAShapeLayer *xValueLayer = [CAShapeLayer layer];
        CGFloat itemValue = isBegin ? [array[self.beginGroupIndex] floatValue] :  [array[self.endGroupIndex] floatValue];
        CGFloat xPoint = self.zeroLine;
        if (itemValue < 0) {
            xPoint = self.zeroLine + itemValue * _dataItemUnitScale;
        }
        NSUInteger leftIndex = isBegin ? self.beginGroupIndex : self.endGroupIndex;
        CGFloat y = leftIndex *(self.zoomedItemAxis*self.Datas.count+self.groupSpace)+i*self.zoomedItemAxis-offsetY;
        UIBezierPath *xValueBezier = [UIBezierPath bezierPathWithRect:CGRectMake(xPoint, y, fabs(itemValue) * _dataItemUnitScale, self.zoomedItemAxis)];
        xValueLayer.path = xValueBezier.CGPath;
        xValueLayer.lineWidth = 1;
        xValueLayer.strokeColor = [[UIColor hexChangeFloat:self.itemColors[i]] CGColor];
        xValueLayer.fillColor = [[UIColor hexChangeFloat:self.itemColors[i]] CGColor];
        [subContainerV.layer addSublayer:xValueLayer];
    }
}

- (void)addAxisLayer {
    CGFloat offsetY = self.gestureScroll.contentOffset.y;
    for (NSUInteger i=self.beginGroupIndex; i<=self.endGroupIndex; i++) {
        CGRect textFrame;
        if (self.chartType == BarChartTypeGroup) {
            if ((self.Datas.count*self.zoomedItemAxis+self.groupSpace)*i - offsetY + (self.Datas.count*self.zoomedItemAxis-TextHeight)/2.0 < 0) continue;
            textFrame = CGRectMake(0, TopEdge+(self.Datas.count*self.zoomedItemAxis+self.groupSpace)*i - offsetY + (self.Datas.count*self.zoomedItemAxis-TextHeight)/2.0, LeftEdge, TextHeight);
        } else {
            if ((self.zoomedItemAxis+self.groupSpace)*i - offsetY + (self.zoomedItemAxis-TextHeight)/2.0 < 0) continue;
            textFrame = CGRectMake(0, TopEdge+(self.zoomedItemAxis+self.groupSpace)*i - offsetY + (self.zoomedItemAxis-TextHeight)/2.0, LeftEdge, TextHeight);
        }
        CATextLayer *text = [self getTextLayerWithString:self.AxisArray[i] textColor:AxisTextColor fontSize:AxistTextFont backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentRight];
        [self.containerView.layer addSublayer:text];
    }
}
- (void)addAxisScaleLayer {
    CAShapeLayer *yScaleLayer = [CAShapeLayer layer];
    UIBezierPath *yScaleBezier = [UIBezierPath bezierPath];
    [yScaleBezier moveToPoint:CGPointMake(LeftEdge, TopEdge)];
    [yScaleBezier addLineToPoint:CGPointMake(LeftEdge, self.bounds.size.height-BottomEdge)];
    yScaleLayer.path = yScaleBezier.CGPath;
    yScaleLayer.lineWidth = ReferenceLineWidth;
    yScaleLayer.strokeColor = AxisScaleColor.CGColor;
    yScaleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.containerView.layer addSublayer:yScaleLayer];
}
- (void)addDataLayer {
    for (NSUInteger i=0; i<_dataNegativeSegmentNum; i++) {
        CGRect textFrame = CGRectMake((i-0.5)*[self axisUnitScale]+LeftEdge, self.bounds.size.height-TextHeight, [self axisUnitScale], TextHeight);
        CATextLayer *text = [self getTextLayerWithString:[NSString stringWithFormat:@"-%@",[self adjustScaleValue:(_dataNegativeSegmentNum-i)*_itemDataScale]] textColor:DataTextColor fontSize:DataTextFont backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentCenter];
        [self.containerView.layer addSublayer:text];
    }
    for (NSInteger i=0; i<=_dataPostiveSegmentNum+1; i++) {
        CGRect textFrame = CGRectMake((_dataNegativeSegmentNum+i-0.5)*[self axisUnitScale]+LeftEdge, self.bounds.size.height-TextHeight, [self axisUnitScale], TextHeight);
        CATextLayer *text = [self getTextLayerWithString:[NSString stringWithFormat:@"%@",[self adjustScaleValue:i*_itemDataScale]] textColor:DataTextColor fontSize:DataTextFont backgroundColor:[UIColor clearColor] frame:textFrame alignmentMode:kCAAlignmentCenter];
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
    CAShapeLayer *xScaleLayer = [CAShapeLayer layer];
    UIBezierPath *xScaleBezier = [UIBezierPath bezierPath];
    [xScaleBezier moveToPoint:CGPointMake(LeftEdge, self.bounds.size.height-BottomEdge)];
    [xScaleBezier addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height-BottomEdge)];
    
    for (NSUInteger i=0; i<=_dataNegativeSegmentNum+_dataPostiveSegmentNum+1; i++) {
        [xScaleBezier moveToPoint:CGPointMake(LeftEdge+i*[self axisUnitScale], self.bounds.size.height-BottomEdge)];
        [xScaleBezier addLineToPoint:CGPointMake(LeftEdge+i*[self axisUnitScale], self.bounds.size.height-BottomEdge+5)];
    }
    xScaleLayer.path = xScaleBezier.CGPath;
    xScaleLayer.lineWidth = ReferenceLineWidth;
    xScaleLayer.strokeColor = AxisScaleColor.CGColor;
    xScaleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.containerView.layer addSublayer:xScaleLayer];
    
    if (_showDataDashLine || !_hideDataHardLine) {
        CAShapeLayer *dashLineLayer = [CAShapeLayer layer];
        UIBezierPath *dashLineBezier = [UIBezierPath bezierPath];
        for (NSUInteger i=1; i<=_dataNegativeSegmentNum+_dataPostiveSegmentNum; i++) {
            [dashLineBezier moveToPoint:CGPointMake(LeftEdge+i*[self axisUnitScale], self.bounds.size.height-BottomEdge)];
            [dashLineBezier addLineToPoint:CGPointMake(LeftEdge+i*[self axisUnitScale], TopEdge)];
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
        if (self.chartType == BarChartTypeGroup) {
            CGFloat h = (ChartHeight-[self.Datas[0] count]*self.groupSpace)/[self.Datas[0] count]/self.Datas.count;
            _itemAxisScale = h > self.minItemWidth ? h : self.minItemWidth;
        } else {
            _itemAxisScale = (ChartHeight/[self.Datas[0] count] - self.groupSpace) > self.minItemWidth ? (ChartHeight/[self.Datas[0] count] - self.groupSpace) : self.minItemWidth;
        }
    }
    return _itemAxisScale;
}
- (CGFloat)zoomedItemAxis {
    return self.itemAxisScale * self.newPinScale * self.oldPinScale;
}
- (CGFloat)axisUnitScale {
    return ChartWidth/(_dataNegativeSegmentNum + _dataPostiveSegmentNum);
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
- (CGFloat)scrollContentSizeHeight {
    if (self.chartType == BarChartTypeGroup) {
        return (self.Datas.count*self.zoomedItemAxis + self.groupSpace) * [self.Datas[0] count];
    }
    return (self.zoomedItemAxis + self.groupSpace) * [self.Datas[0] count];
}
- (CGFloat)zeroLine {
    return self.dataNegativeSegmentNum * [self axisUnitScale];
}
@end
