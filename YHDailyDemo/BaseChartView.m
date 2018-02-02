//
//  BaseChartView.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/2/2.
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

#import "BaseChartView.h"
#import "UIColor+HexColor.h"

typedef NS_ENUM(NSUInteger,BarChartType) {
    BarChartTypeSingle = 0,
    BarChartTypeGroup = 1,
    BarChartTypeStack = 2
};

@interface BaseChartView()<UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *gestureScroll;
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

@implementation BaseChartView
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
    self.isDataError = !self.AxisArray || ![self.AxisArray isKindOfClass:[NSArray class]] || !self.Datas || ![self.Datas isKindOfClass:[NSArray class]];
    
    self.groupMembers = [dict objectForKey:@"groupMembers"];
    self.axisTitle = [dict objectForKey:@"axisTitle"];
    self.dataTitles = [dict objectForKey:@"dataTitles"];
    self.barColors = [dict objectForKey:@"colors"];
    if (!self.barColors) {
        [self defaultColors];
    }
    self.chartType = [[dict objectForKey:@"displayType"] integerValue];
    self.valueInterval = [[dict objectForKey:@"valueInterval"] integerValue];
    if (self.valueInterval == 0) {
        self.valueInterval = 4;
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
//    switch (pinGesture.state) {
//        case UIGestureRecognizerStateBegan: {
//            CGPoint pinCenterContainer = [pinGesture locationInView:self.containerView];
//            _pinCenterToLeftDistance = pinCenterContainer.x - LeftEdge;
//            CGPoint pinCenterScrollView = [pinGesture locationInView:self.gestureScroll];
//            _pinCenterRatio = pinCenterScrollView.x/self.gestureScroll.contentSize.width;
//        }
//            break;
//        case UIGestureRecognizerStateChanged: {
//            if (pinGesture.scale < 1){
//                CGFloat testZoomedWidth = 0;
//                if (self.chartType == BarChartTypeGroup) {
//                    testZoomedWidth = ([self.Datas count]*self.itemW*self.oldPinScale*pinGesture.scale + self.groupSpace) * [self.Datas[0] count];
//                } else {
//                    testZoomedWidth = (self.itemW*self.oldPinScale*pinGesture.scale + self.groupSpace) * [self.Datas[0] count];
//                }
//                if (testZoomedWidth < ChartWidth) {
//                    if (self.chartType == BarChartTypeGroup) {
//                        _newPinScale = (ChartWidth/[self.Datas[0] count] - self.groupSpace)/self.Datas.count/self.itemW/self.oldPinScale;
//                    } else {
//                        _newPinScale = (ChartWidth/[self.Datas[0] count] - self.groupSpace)/self.itemW/self.oldPinScale;
//                    }
//                } else {
//                    _newPinScale = pinGesture.scale;
//                }
//            } else {
//                _newPinScale = pinGesture.scale;
//            }
//            [self adjustScroll];
//            [self redraw];
//        }
//            break;
//        case UIGestureRecognizerStateEnded: {
//            _oldPinScale *= _newPinScale;
//        }
//            break;
//
//        default:
//            break;
//    }
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
//    self.gestureScroll.contentSize = CGSizeMake(self.scrollContentSizeWidth, ChartHeight);
//    CGFloat offsetX = self.gestureScroll.contentSize.width * self.pinCenterRatio - self.pinCenterToLeftDistance;
//    if (offsetX < 0) {
//        offsetX = 0;
//    }
//    if (self.gestureScroll.contentSize.width > ChartWidth) {
//        if (offsetX > self.gestureScroll.contentSize.width - ChartWidth) {
//            offsetX = self.gestureScroll.contentSize.width - ChartWidth;
//        }
//    } else {
//        offsetX = 0;
//    }
//    self.gestureScroll.contentOffset = CGPointMake(offsetX, 0);
}
- (void)redraw {
    [_containerView removeFromSuperview];
    _containerView = nil;
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    _containerView.backgroundColor = [UIColor clearColor];
    
    [self insertSubview:_containerView belowSubview:_gestureScroll];
//    [self findBeginAndEndIndex];
//    [self calculateMaxAndMinValue];
//    [self calculateYAxisSegment];
//    [self drawYValuePoint];
//    [self addXAxisLayer];
//    [self addXScaleLayer];
//    [self addYAxisLayer];
//    [self addYScaleLayer];
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
