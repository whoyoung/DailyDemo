//
//  CoreAnimationDrawView.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/1/19.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "CoreAnimationDrawView.h"

@interface CoreAnimationDrawView()
@property (nonatomic, strong) NSArray *points;
@property (nonatomic, weak) CAShapeLayer *axisLayer;
@property (nonatomic, weak) CAShapeLayer *timeLineLayer;
@property (nonatomic, weak) CAShapeLayer *backgroudFillLayer;
@end

@implementation CoreAnimationDrawView

- (void)layoutSubviews {
    [super layoutSubviews];
    if(!_axisLayer) {
        [self.layer addSublayer:self.axisLayer];
        [self addTextLayer];
        [self addTimeLineAndBackgroundFillLayer];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(redraw)];
        [self addGestureRecognizer:tap];
    }
}

- (CAShapeLayer *)axisLayer {
    if (!_axisLayer) {
        CAShapeLayer *frameLayer = [CAShapeLayer layer];
        CGFloat frameX = 50, frameY = 10;
        CGFloat frameW = self.bounds.size.width-frameX*2, frameH = self.bounds.size.height-frameY-20;
        CGRect frameRect = CGRectMake(frameX, frameY, frameW, frameH);
        
        UIBezierPath *framePath = [UIBezierPath bezierPathWithRect:frameRect];
        CGFloat unitW = frameW/6;
        CGFloat unitH = frameH/4;
        //7条竖线
        for (NSUInteger i=0; i<7; i++) {
            CGPoint startP = CGPointMake(frameX+unitW*i, frameY);
            CGPoint endP = CGPointMake(frameX+unitW*i, frameY+frameH);
            [framePath moveToPoint:startP];
            [framePath addLineToPoint:endP];
        }
        
        //5条横线
        for(NSUInteger i=0;i<6;i++) {
            CGPoint startP = CGPointMake(frameX, frameY+i*unitH);
            CGPoint endP = CGPointMake(frameX+frameW, frameY+i*unitH);
            [framePath moveToPoint:startP];
            [framePath addLineToPoint:endP];
        }
        
        frameLayer.path = framePath.CGPath;
        frameLayer.lineWidth = 1;
        frameLayer.strokeColor = [UIColor blackColor].CGColor;
        frameLayer.fillColor = [UIColor clearColor].CGColor;
        _axisLayer = frameLayer;
    }
    return _axisLayer;
}
- (void)addTextLayer {
    CGFloat axisX = 50;
    CGFloat axisMaxY = self.bounds.size.height-15;
    CGFloat axisUnitW = (self.bounds.size.width-axisX*2)/6;
    for (NSUInteger i=0; i<6; i++) {
        CGRect textFrame = CGRectMake(axisX+axisUnitW/2.0 + axisUnitW*i, axisMaxY, axisUnitW, 15);
        CATextLayer *text = [self getTextLayerWithString:[NSString stringWithFormat:@"x%ld",i] textColor:[UIColor blackColor] fontSize:12 backgroundColor:[UIColor clearColor] frame:textFrame];
        [self.layer addSublayer:text];
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
    //设置分辨率
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    return textLayer;
}
- (void)addTimeLineAndBackgroundFillLayer {
    CAShapeLayer *timeLineLayer = [CAShapeLayer layer];
    CAShapeLayer *backgroudFillLayer = [CAShapeLayer layer];
    
    NSMutableArray *points = [self pointsArray];
    CGPoint startP = CGPointFromString([points firstObject]);
    UIBezierPath *lineB = [UIBezierPath bezierPath];
    [lineB moveToPoint:startP];
    for (NSUInteger i=1; i<points.count; i++) {
        CGPoint nextP = CGPointFromString(points[i]);
        [lineB addLineToPoint:nextP];
    }
    timeLineLayer.path = lineB.CGPath;
    timeLineLayer.lineWidth = 0.5;
    timeLineLayer.strokeColor = [UIColor blueColor].CGColor;
    timeLineLayer.fillColor = [UIColor clearColor].CGColor;
    _timeLineLayer = timeLineLayer;
    
    CGPoint endP = CGPointFromString([points lastObject]);
    [lineB addLineToPoint:CGPointMake(endP.x, CGRectGetHeight(self.bounds)-20)];
    [lineB addLineToPoint:CGPointMake(startP.x, CGRectGetHeight(self.bounds)-20)];
    backgroudFillLayer.path = lineB.CGPath;
    backgroudFillLayer.fillColor = [UIColor blueColor].CGColor;
    backgroudFillLayer.opacity = 0.5;
    backgroudFillLayer.strokeColor = [UIColor clearColor].CGColor;
    backgroudFillLayer.zPosition -= 1;
    _backgroudFillLayer = backgroudFillLayer;
    
    [self.layer addSublayer:timeLineLayer];
    [self.layer addSublayer:backgroudFillLayer];
}
- (NSMutableArray *)pointsArray {
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:50];
    CGFloat startX = 50;
    for (NSUInteger i=0; i<5000; i++) {
        startX += 0.1;
        CGFloat y = 10 + arc4random_uniform(100);
        CGPoint point = CGPointMake(startX, y);
        [points addObject:NSStringFromCGPoint(point)];
    }
    return points;
}
- (void)redraw {
    [_backgroudFillLayer removeFromSuperlayer];
    [_timeLineLayer removeFromSuperlayer];
    _backgroudFillLayer = nil;
    _timeLineLayer = nil;
    [self addTimeLineAndBackgroundFillLayer];
}
@end
