//
//  IPConvertNumDemoViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/3/31.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "IPConvertNumDemoViewController.h"

@interface IPConvertNumDemoViewController ()

@end

@implementation IPConvertNumDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    NSString *ipStr = @"192.168.0.25";
    NSUInteger ipNum = [self ipConvertNum:ipStr];
    NSLog(@"ipNum======%ld",ipNum);
    NSString *convertedIp = [self numConvertIp:ipNum];
    NSLog(@"convertedIp=====%@",convertedIp);
}
- (NSUInteger)ipConvertNum:(NSString *)ipStr {
    NSArray *array = [ipStr componentsSeparatedByString:@"."];
    if (array.count == 4) {
        return [array[0] integerValue] *pow(256, 3)+[array[1] integerValue]*pow(256, 2)+[array[2] integerValue]*pow(256, 1)+[array[3] integerValue]*pow(256, 0);
    }
    return 0;
}
- (NSString *)numConvertIp:(NSUInteger)ipNum {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:4];
    NSUInteger tempNum = ipNum;
    for (NSUInteger i=4; i>0; i--) {
        NSUInteger num = [self originNum:tempNum pow256:i-1];
        [array addObject:[NSString stringWithFormat:@"%lu",num]];
        tempNum -= num * pow(256, i-1);
    }
    return [array componentsJoinedByString:@"."];
}
- (NSUInteger)originNum:(NSUInteger)num pow256:(NSUInteger)powNum {
    return num/pow(256,powNum);
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
