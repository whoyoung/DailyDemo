//
//  FindMaxAndMinNumberViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/1/19.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "FindMaxAndMinNumberViewController.h"

@interface FindMaxAndMinNumberViewController ()
@property (nonatomic, strong) NSArray *yArray;
@property (nonatomic, assign) CGFloat min;
@property (nonatomic, assign) CGFloat max;

@end

@implementation FindMaxAndMinNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _yArray = @[@"22",@"3",@"19",@"7",@"8"];
    self.min = [_yArray[0] floatValue];
    self.max = [_yArray[0] floatValue];
    [self findMaxAndMinValue:0 rightIndex:_yArray.count-1];
    
    UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.text = [NSString stringWithFormat:@"数组：\n%@\n max= %f \nmin= %f",self.yArray,self.max,self.min];
    [self.view addSubview:label];
}
- (void)findMaxAndMinValue:(NSUInteger)leftIndex rightIndex:(NSUInteger)rightIndex {
    if (leftIndex == rightIndex) {
        self.min = MIN([self.yArray[leftIndex] floatValue], self.min);
        self.max = MAX([self.yArray[leftIndex] floatValue], self.max);
        return;
    } else if(leftIndex == rightIndex-1) {
        if ([self.yArray[leftIndex] floatValue] < [self.yArray[rightIndex] floatValue]) {
            self.min = MIN([self.yArray[leftIndex] floatValue], self.min);
            self.max = MAX([self.yArray[rightIndex] floatValue], self.max);
            return;
        } else {
            self.min = MIN([self.yArray[rightIndex] floatValue], self.min);
            self.max = MAX([self.yArray[leftIndex] floatValue], self.max);
            return;
        }
    }
    NSUInteger mid = (leftIndex + rightIndex)/2;
    [self findMaxAndMinValue:leftIndex rightIndex:mid];
    [self findMaxAndMinValue:mid + 1 rightIndex:rightIndex];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
