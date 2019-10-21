//
//  MyCollectionViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/10/21.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "MyCollectionViewController.h"

@interface MyCollectionViewController ()

@property (nonatomic,strong) NSArray *datas;

@end

@implementation MyCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.datas.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ((NSArray *)(self.datas[section])).count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    UILabel *label = [cell.contentView viewWithTag:100];
    if (!label) {
        label = [[UILabel alloc] init];
        label.tag = 100;
        label.textColor = [UIColor blueColor];
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentCenter;
        label.contentMode = UIViewContentModeCenter;
        [cell.contentView addSubview:label];
        label.frame = cell.bounds;
    }
    label.text = self.datas[indexPath.section][indexPath.row];
    return cell;
}

- (NSArray *)datas {
    if (!_datas) {
        _datas = @[@[@"0"],@[@"1"],@[@"2"],@[@"3"],@[@"4"],@[@"5"],@[@"6"],@[@"7"],@[@"8"],@[@"9"]];
    }
    return _datas;
}

@end
