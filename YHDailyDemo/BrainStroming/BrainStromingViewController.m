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

//    [self decoderUTF8String];
//    [self decodeBase64Str];
//    [self arrayToDict];
    [self sendMessageToNil];
//    NSUInteger timeStamp = @([NSDate date].timeIntervalSince1970).unsignedIntValue * 1000;
//    NSArray *array = @[@{@"timestamp":@"timeStamp"}];
//    NSDictionary *dict = @{@"timestamp":@"timeStamp"};
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"stamp",@"key", nil];
    NSArray *array = @[dict];
    NSLog(@"%@",array);
}

- (void)sendMessageToNil {
    NSDictionary *dict = @{};
    NSDictionary *subDict = [dict objectForKey:@"test"];
    NSUInteger number = [[subDict objectForKey:@"number"] integerValue];
    NSLog(@"number = %ld",number);
    
    NSDictionary *indexDict = dict[@"test"];
    NSUInteger indexNumber = [indexDict[@"number"] integerValue];
    NSLog(@"indexNumber = %ld",indexNumber);
}

- (void)arrayToDict {
    NSArray *arr = @[@"a",@"b",@"c"];
    NSDictionary *dict = (NSDictionary *)arr;
    NSLog(@"dict === %@",dict);
}

- (void)decodeBase64Str {
    NSString *str = @"WwogIDAsCiAgMCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAyNTQsCiAgMjU0LAogIDI1NCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwLAogIDAsCiAgMCwKICAwCl0=";
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSArray *hrs = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"%@",[hrs componentsJoinedByString:@","]);
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
