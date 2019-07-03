//
//  FindValueInTwoDimensionalArrayViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/4/1.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "FindValueInTwoDimensionalArrayViewController.h"

@interface FindValueInTwoDimensionalArrayViewController ()

@end

@implementation FindValueInTwoDimensionalArrayViewController
//在一个二维数组中，每一行都按照从左到右递增的顺序排序，每一列都按照从上到下递增的顺序排序。请完成一个函数，输入这样的一个二维数组和一个整数，判断数组中是否含有该整数。
/* 思路： 依次比较右上角的数字；如果该数字大于要查找的数字，则剔除列；如果该数字小于要查找的数字，则剔除行；
 复杂度：O(m+n), 行数m，列数n */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSArray *array = @[@[@1,@33,@55,@332,@444],@[@2,@44,@66,@344,@456]];
    BOOL isExisted = [self isExistNumer:66 inArray:array];
    NSLog(@"isExisted=====%d",isExisted);
    NSString *originStr = @"h e l l o";
    
    NSString *newStr = [originStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"%@",newStr);
}
- (BOOL)isExistNumer:(NSUInteger)num inArray:(NSArray *)array {
    if (!array || !array.count || ![array[0] count]) return NO;
    NSUInteger totalRow = array.count;
    NSUInteger totalColumn = [array[0] count];
    NSInteger row = 0, column = totalColumn - 1;
    BOOL isExisted = NO;
    while (row < totalRow && column >= 0) {
        NSUInteger tempNum = [array[row][column] integerValue];
        if (tempNum == num) {
            isExisted = YES;
            NSLog(@"row===%d, column=====%d",row,column);
            break;
        } else if (tempNum < num) {
            row++;
        } else {
            column--;
        }
    }
    return isExisted;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
