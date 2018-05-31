//
//  TableViewRegisterClassController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2018/5/31.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "TableViewRegisterClassController.h"
#import "CustomTableViewCell.h"

@interface TableViewRegisterClassController ()

@end

@implementation TableViewRegisterClassController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[CustomTableViewCell class] forCellReuseIdentifier:@"cell"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
//    if (!cell) {
//        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.textColor = [UIColor blackColor];
//    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    
    return cell;
}

@end
