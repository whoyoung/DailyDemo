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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSArray *array = @[@[@1,@33,@55,@332,@444],@[@2,@44,@66,@344,@456]];
    BOOL isExisted = [self isExistNumer:66 inArray:array];
    NSLog(@"isExisted=====%d",isExisted);
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
