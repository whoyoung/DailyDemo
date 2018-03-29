//
//  MemoryMapDemoViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/3/29.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "MemoryMapDemoViewController.h"

@interface MemoryMapDemoViewController ()
@property (nonatomic, strong) NSData *data;
@end

@implementation MemoryMapDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSString *filePath = [self getFilePath:@"SourceTree_2.0.5.5"];
//    _data = [NSData dataWithContentsOfFile:filePath];
    _data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
    NSLog(@"finish===%ld",_data.length);

}
- (NSString *)getFilePath:(NSString *)fileName {
    NSString *filePath = [[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"dmg"];;
    return filePath;
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
