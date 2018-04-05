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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSString *str = @"222";
//
//    NSString *copyStr = [str copy];
//    NSMutableString *mutableCopyStr = [str mutableCopy];
//    NSLog(@"str====%p, copyStr====%p , mutableCopyStr====%p",str,copyStr,mutableCopyStr);
//
//    str = @"333";
//    NSLog(@"str====%p, copyStr====%p , mutableCopyStr====%p",str,copyStr,mutableCopyStr);
    
    NSMutableString *mStr = [NSMutableString stringWithFormat:@"222"];
    NSMutableString *mStrCopy = [mStr copy];
    NSMutableString *mStrMCopy = [mStr mutableCopy];
    NSString *strCopy = [mStr copy];
    NSString *strMCopy = [mStr mutableCopy];
    
    NSLog(@"mStr=%p, mStrCopy=%p ,mStrMCopy=%p, strCopy=%p, strMCopy=%p",mStr,mStrCopy,mStrMCopy,strCopy,strMCopy);
    
    [mStr appendString:@"333"];
    NSLog(@"mStr=%@, mStrCopy=%@ ,mStrMCopy=%@, strCopy=%@, strMCopy=%@",mStr,mStrCopy,mStrMCopy,strCopy,strMCopy);
    NSLog(@"mStr=%p, mStrCopy=%p ,mStrMCopy=%p, strCopy=%p, strMCopy=%p",mStr,mStrCopy,mStrMCopy,strCopy,strMCopy);
    
    [mStrMCopy appendString:@"444"];
    NSLog(@"mStrCopy=====%@, strMCopy===%@",mStrMCopy,strMCopy);
    
}

@end
