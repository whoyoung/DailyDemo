//
//  FormulaCalculateViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/2/21.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "FormulaCalculateViewController.h"

@interface FormulaCalculateViewController () <UIScrollViewDelegate>

@end

@implementation FormulaCalculateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat cal = [self hrToCalorieWithHRPoints:@[@80,@80,@80,@80,@80,@80,@80,@80,@80,@80,@80,@80]];
    NSLog(@"cal = %f",cal);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(testNoti) name:@"testNotification" object:nil];
    
    UIScrollView *scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, 200, 200)];
    scrollV.contentSize = CGSizeMake(400, 200);
    scrollV.contentInset = UIEdgeInsetsMake(0, 100, 0, 0);
    scrollV.backgroundColor = [UIColor grayColor];
    scrollV.delegate = self;
    [self.view addSubview:scrollV];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollView.contentOffset.x = %f",scrollView.contentOffset.x);
}

- (void)testNoti {
    
}

//max {REE,EE}
//男性REE（每分钟）= (66.5+13.75*weight(kg)+5.003*height(cm)-6.775*age)/1440;
//女性REE（每分钟）= (655.1+9.563*weight(kg)+1.85*height(cm)-4.676*age)/1440。(默认的身高体重为：男身高 175 cm，男体重 70 kg；女身高 165 cm，女体重 50 kg)
//男性EE（每分钟） =( -55.0969 + 0.6309 * HR + 0.1988 *weight + 0.2017 * age ) / 4.184;
//女性EE（每分钟）= ( -20.4022 + 0.4472 * HR - 0.1263 * weight + 0.074 * age) / 4.184.
- (CGFloat)hrToCalorieWithHRPoints:(NSArray<NSNumber *> *)points {
    CGFloat freConstant = 5 / 60.0;
    CGFloat age = 28, weight = 65, height = 175;
    NSString *gender = @"M";
    CGFloat calEE = 0;
    for (NSNumber *number in points) {
        NSInteger hrSum = [number integerValue];
        if (hrSum >= 0) {
            CGFloat tempCal = 0;
            if ([gender isEqualToString:@"M"]) {
                tempCal = freConstant * (-55.0969 + 0.6309 * hrSum + 0.1988 * weight + 0.2017 * age ) / 4.184;
            } else {
                tempCal = freConstant * (-20.4022 + 0.4472 * hrSum * freConstant - 0.1263 * weight + 0.074 * age) / 4.184;
            }
            if (tempCal >= 0) {
                calEE += tempCal;
            }
        }
    }
    
    CGFloat calREE = 0;
    if ([gender isEqualToString:@"M"]) {
        calREE = points.count * freConstant * (66.5 + 13.75 * weight + 5.003 * height - 6.775 * age) / 1440;
    } else {
        calREE = points.count * freConstant * (655.1 + 9.563 * weight + 1.85 * height - 4.676 * age) / 1440;
    }
    if (calREE < 0) {
        calREE = 0;
    }
    return MAX(calEE, calREE);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
