//
//  CommonMoreImage.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/12/10.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "CommonMoreImage.h"

@implementation CommonMoreImage

+ (UIImage *)moreImage {
    static UIImage *image;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [[UIImage imageNamed:@"feed_card_more_action"]  imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    });
    return image;
}

@end
