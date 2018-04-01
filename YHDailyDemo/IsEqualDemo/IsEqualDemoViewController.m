//
//  IsEqualDemoViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/4/1.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "IsEqualDemoViewController.h"
#import "IsEqualObject.h"
@interface IsEqualDemoViewController ()

@end

@implementation IsEqualDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    NSNumber *num1 = @1;
    NSNumber *num2 = @1;
    NSLog(@"[num1 isEqual:num2]====%d",[num1 isEqual:num2]); //默认是根据值来判断是否相等
    NSLog(@"num1==%p, num2==%p",num1,num2);
    NSLog(@"NSNumber hash1==%ld, hash2==%ld *****************",[num1 hash],[num2 hash]);
    
    NSString *str1 = @"1";
    NSString *str2 = @"1";
    NSLog(@"[str1 isEqual:str2]====%d",[str1 isEqual:str2]); //默认是根据值来判断是否相等
    NSLog(@"str1==%p, str2==%p",str1,str2);
    NSLog(@"NSString hash1==%ld, hash2==%ld *****************",[str1 hash],[str2 hash]);
    
    NSMutableString *mutaStr1 = [NSMutableString stringWithFormat:@"1"];
    NSMutableString *mutaStr2 = [NSMutableString stringWithFormat:@"1"];
    NSLog(@"[mutaStr1 isEqual:mutaStr2]====%d",[mutaStr1 isEqual:mutaStr2]); //默认是根据值来判断是否相等
    NSLog(@"mutaStr1==%p, mutaStr2==%p",mutaStr1,mutaStr2);
    NSLog(@"NSMutableString hash1==%ld, hash2==%ld *****************",[mutaStr1 hash],[mutaStr2 hash]);

    IsEqualObject *obj1 = [[IsEqualObject alloc] initWithName:@"1"];
    IsEqualObject *obj2 = [[IsEqualObject alloc] initWithName:@"1"];
    NSLog(@"[obj1 isEqual:obj2]====%d",[obj1 isEqual:obj2]); //默认是根据内存地址来判断是否相等
    NSLog(@"obj1==%p, obj2==%p",obj1,obj2);
    NSLog(@"IsEqualObject hash1==%ld, hash2==%ld *****************",[obj1 hash],[obj2 hash]);

    NSArray *array1 = @[@1];
    NSArray *array2 = @[@1];
    NSLog(@"[array1 isEqual:array2]====%d",[array1 isEqual:array2]); //默认是根据每个元素的值来判断是否相等
    NSLog(@"array1==%p, array2==%p",array1[0],array2[0]);
    NSLog(@"NSArray hash1==%ld, hash2==%ld *****************",[array1 hash],[array2 hash]);
    
    NSMutableArray *mutaArray1 = [NSMutableArray arrayWithObject:@"1"];
    NSMutableArray *mutaArray2 = [NSMutableArray arrayWithObject:@"1"];
    NSLog(@"[mutaArray1 isEqual:mutaArray2]====%d",[mutaArray1 isEqual:mutaArray2]); //默认是根据每个元素的值来判断是否相等
    NSLog(@"mutaArray1==%p, mutaArray2==%p",mutaArray1,mutaArray2);
    NSLog(@"NSMutableArray hash1==%ld, hash2==%ld *****************",[mutaArray1 hash],[mutaArray2 hash]);

    
    NSDictionary *dict1 = @{@"1":@1};
    NSDictionary *dict2 = @{@"1":@1};
    NSLog(@"[dict1 isEqual:dict2]====%d",[dict1 isEqual:dict2]); //默认是根据每个元素的值来判断是否相等
    NSLog(@"dict1==%p, dict2==%p",dict1,dict2);
    NSLog(@"NSDictionary hash1==%ld, hash2==%ld *****************",[dict1 hash],[dict2 hash]);

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
