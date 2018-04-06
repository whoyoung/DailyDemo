//
//  MultiTableViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/4/6.
//  Copyright © 2018年 杨虎. All rights reserved.
//
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#import "MultiTableViewController.h"

@interface MultiTableViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *datas;
@property (nonatomic, strong) UITableView *table1;
@property (nonatomic, strong) UITableView *table2;
@end

@implementation MultiTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _table1 = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, kScreenWidth, 200) style:UITableViewStylePlain];
    _table1.delegate = self;
    _table1.dataSource = self;
    [self.view addSubview:_table1];
    
    _table2 = [[UITableView alloc] initWithFrame:CGRectMake(0, 300, kScreenWidth, 200) style:UITableViewStylePlain];
    _table2.delegate = self;
    _table2.dataSource = self;
    [self.view addSubview:_table2];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //多个tableview共用同一个identifier是没问题的，因为每个tableview都有自己的缓存池，取缓存的cell也仅仅在自己的缓存池中取
    static NSString *identifier = @"commonCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = [UIColor blackColor];
        if (tableView == self.table2) {
            cell.backgroundColor = [UIColor orangeColor];
        }
    }
    cell.textLabel.text = self.datas[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (NSArray *)datas {
    if (!_datas) {
        _datas = @[@"row1",@"row2",@"row3",@"row4",@"row5",@"row6",@"row7",@"row8",@"row9"];
    }
    return _datas;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
