//
//  BrainStromingViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/6/4.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "BrainStromingViewController.h"

@interface BrainStromingViewController ()

@end

@implementation BrainStromingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self decoderUTF8String];
}

- (void)decoderUTF8String {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"dataString" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *originStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"originStr === %@",originStr);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"title"
                                                                             message: @"message"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *_Nonnull action) {
                                                              
                                                          }]];
    
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (controller.presentedViewController) {
        controller = controller.presentedViewController;
    }
    [controller presentViewController:alertController
                             animated:YES
                           completion:nil];
}

@end
