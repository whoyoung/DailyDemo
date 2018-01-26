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
@end

@implementation CoreAnimationDrawView

- (void)layoutSubviews {
    [super layoutSubviews];
    if(!_axisLayer) {
        [self.layer addSublayer:self.axisLayer];
        [self addTextLayer];
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
@end
