//
//  CopyStrongDemoViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/3/13.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "CopyStrongDemoViewController.h"

@interface CopyStrongDemoViewController ()
@property (nonatomic, copy) NSString *strCopy;
@property (nonatomic, strong) NSString *strStrong;
@property (nonatomic, copy) NSMutableString *strMutableCopy;
@property (nonatomic, strong) NSMutableString *strMutableStrong;

@property (nonatomic, copy) NSArray *arrayCopy;
@property (nonatomic, strong) NSArray *arrayStrong;
@property (nonatomic, copy) NSMutableArray *arrayMutableCopy;
@property (nonatomic, strong) NSMutableArray *arrayMutableStrong;

@end

@implementation CopyStrongDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSMutableString *mutStr = [NSMutableString stringWithFormat:@"prefix"];
    self.strCopy = mutStr;
    self.strStrong = mutStr;
    self.strMutableCopy = mutStr;
    self.strMutableStrong = mutStr;
    NSLog(@"mutStr=%@,%p",mutStr,mutStr);
    NSLog(@"_strCopy=%@,%p",_strCopy,_strCopy);
    NSLog(@"_strStrong=%@,%p",_strStrong,_strStrong);
    NSLog(@"_strMutableCopy=%@,%p",_strMutableCopy,_strMutableCopy);
    NSLog(@"_strMutableStrong=%@,%p",_strMutableStrong,_strMutableStrong);

    [mutStr appendString:@"+suffix"];
    NSLog(@"_strCopy=%@,%p",_strCopy,_strCopy);
    NSLog(@"_strStrong=%@,%p",_strStrong,_strStrong);
    NSLog(@"_strMutableCopy=%@,%p",_strMutableCopy,_strMutableCopy);
    NSLog(@"_strMutableStrong=%@,%p",_strMutableStrong,_strMutableStrong);
    
    
    NSMutableArray *mutArray = [NSMutableArray arrayWithObject:@"first"];
    _arrayCopy = mutArray;
    _arrayStrong = mutArray;
    _arrayMutableCopy = mutArray;
    _arrayMutableStrong = mutArray;
    NSLog(@"%@,%p",_arrayCopy,_arrayCopy);
    NSLog(@"%@,%p",_arrayStrong,_arrayStrong);
    NSLog(@"%@,%p",_arrayMutableCopy,_arrayMutableCopy);
    NSLog(@"%@,%p",_arrayMutableStrong,_arrayMutableStrong);
    
    [mutArray addObject:@"last"];
    NSLog(@"%@,%p",_arrayCopy,_arrayCopy);
    NSLog(@"%@,%p",_arrayStrong,_arrayStrong);
    NSLog(@"%@,%p",_arrayMutableCopy,_arrayMutableCopy);
    NSLog(@"%@,%p",_arrayMutableStrong,_arrayMutableStrong);

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
