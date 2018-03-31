//
//  NSUserDefaultsSaveObjectViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/3/31.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "NSUserDefaultsSaveObjectViewController.h"
#import "CustomizeObject.h"
@interface NSUserDefaultsSaveObjectViewController ()

@end

@implementation NSUserDefaultsSaveObjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"dddddd");
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self saveOCObject];
    [self saveCustomizeObject];
}
- (void)saveOCObject {
    //NSUserDefaults支持的数据类型有：NSNumber（NSInteger、float、double），NSString，NSDate，NSArray，NSDictionary，BOOL.
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"date"];
    NSLog(@"date=====%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"date"]);
}
- (void)saveCustomizeObject {
    CustomizeObject *obj = [[CustomizeObject alloc] initWithName:@"whoyoung" height:2.0];
    
//    [[NSUserDefaults standardUserDefaults] setObject:obj forKey:@"CustomizeObject"]; //沙盒不可以直接存储自定义的对象，可转化为NSData存储
    
    NSData *objData = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [[NSUserDefaults standardUserDefaults] setObject:objData forKey:@"CustomizeObject"];
    
    NSData *readData = [[NSUserDefaults standardUserDefaults] objectForKey:@"CustomizeObject"];
    CustomizeObject *readObj = [NSKeyedUnarchiver unarchiveObjectWithData:readData];
    NSLog(@"readObj.name=====%@",readObj.name);
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
