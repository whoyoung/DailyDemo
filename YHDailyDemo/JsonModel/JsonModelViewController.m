//
//  JsonModelViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/8/30.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "JsonModelViewController.h"
#import "CustomJsonModel.h"

@interface JsonModelViewController ()

@end

@implementation JsonModelViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CustomJsonModel *model = [[CustomJsonModel alloc] init];
    model.string = @"string";
    model.attrString = [[NSAttributedString alloc] initWithString:@"attrString" attributes:@{
                                                                                             NSFontAttributeName : [UIFont systemFontOfSize:14],
                                                                                             NSLinkAttributeName : [NSURL URLWithString:@"http://www.baidu.com"]
                                                                                             }];
    NSDictionary *dict = [model toDictionary]; 
    NSLog(@"dict = %@",dict);
}

@end
