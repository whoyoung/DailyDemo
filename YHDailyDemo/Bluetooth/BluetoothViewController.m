//
//  BluetoothViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/8/16.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "BluetoothViewController.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface BluetoothViewController () <CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager *manager;

@end

@implementation BluetoothViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_queue_t bleQueue = dispatch_queue_create("bleQueue", DISPATCH_QUEUE_CONCURRENT);
    
    NSDictionary *dic = @{CBCentralManagerOptionShowPowerAlertKey : @(YES),
                          CBCentralManagerOptionRestoreIdentifierKey : @"KLBluetoothIdentifier"
                          };
//    NSArray *array = [[NSBundle mainBundle].infoDictionary objectForKey:@"UIBackgroundModes"];
//    if ([array containsObject:@"bluetooth-central"]) {
//        _centralManager = [[CBCentralManager alloc] initWithDelegate:self
//                                                               queue:dispatch_queue_create("com.link.bluetooth", NULL)
//                                                             options:dic];
//    } else {
//        _centralManager = [[CBCentralManager alloc] initWithDelegate:self
//                                                               queue:dispatch_queue_create("com.link.bluetooth", NULL)
//                                                             options:nil];
//    }
    
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:bleQueue options:dic];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    CBManagerState state = central.state;
    NSLog(@"state = %ld",state);
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict {
    NSLog(@"willRestoreState");
}


@end
