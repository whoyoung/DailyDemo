//
//  RootTableViewController.m
//  ChartCoordinateAxis
//
//  Created by 杨虎 on 2018/1/18.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "RootTableViewController.h"

@interface RootTableViewController ()

@end

@implementation RootTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"RootViewController"];
    NSArray *vcs = @[@"YHHitTestViewController",@"YHCornerAndShadowViewController",@"YHPushSelfViewController",@"YHIGListDemoViewController",@"YHFlowLayoutViewController",@"NotiBlockViewController",@"AssertDemoViewController",@"TTTAttributedLabelViewController",@"AlgorithmViewController",@"JsonModelViewController",@"BluetoothViewController",@"NSPointerArrayAndNSMutabelSetViewController",@"CustomNotificationCenterViewController",@"EnumerateDemoViewController",@"SynchronizedDemoVC",@"WeakIVarViewController",@"BrainStromingViewController",@"ZeroClockViewController",@"ScrollViewAndLongPressGestureViewController",@"FormulaCalculateViewController",@"ForInDeleteViewController",@"MLeaksFinderDemoViewController",@"WeakStrongObjectDemoViewController",@"TableViewRegisterClassController",@"MultiTableViewController",@"MultiCategoryViewController",@"IsEqualDemoViewController",@"SingleTonViewController",@"FindValueInTwoDimensionalArrayViewController",@"NestedBlockDemoViewController",@"IPConvertNumDemoViewController",@"NSUserDefaultsSaveObjectViewController",@"FindMaxAndMinNumberViewController",@"DrawViewController",@"LineChartViewController",@"HorizontalBarChartViewController",@"VerticalBarChartViewController",@"SemaphoreViewController",@"RespondChainViewController",@"CopyStrongDemoViewController",@"NSProxyDemoViewController",@"NSProxyMultiInheritDemoViewController",@"LockDemoViewController",@"AssignObjectDemoViewController",@"MemoryMapDemoViewController",@"RevertStringDemoViewController",];
    [self.datas addObjectsFromArray:vcs];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.frame = CGRectMake(0,20, self.navigationController.navigationBar.frame.size.width,44);
//    [self setNeedsStatusBarAppearanceUpdate];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Class cls = NSClassFromString(self.datas[indexPath.row]);
    UIViewController *vc = [[cls alloc] init];
    if ([self.datas[indexPath.row] isEqualToString:@"DismissViewController"]) {
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

//- (BOOL)prefersStatusBarHidden {
//    return NO;
//}

@end
