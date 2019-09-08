//
//  BrainStromingViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/6/4.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "BrainStromingViewController.h"
#import "YHTempViewController.h"

@interface BrainStromingViewController ()

@property (nonatomic, strong) NSArray *datas;

@end

@implementation BrainStromingViewController

- (void)viewDidLoad {
    [super viewDidLoad]; 
    self.datas = @[@"decoderUTF8String",@"decodeBase64Str",@"arrayToDict",@"sendMessageToNil",@"topController",@"postNotification",@"toTempViewController",@"keyValueType"];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.datas[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *selString = self.datas[indexPath.row];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:NSSelectorFromString(selString)];
#pragma clang diagnostic pop
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

- (void)topController {
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

- (void)postNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)toTempViewController {
    [self.navigationController pushViewController:[YHTempViewController new] animated:YES];
}

- (void)keyValueType {
//    NSMutableDictionary *dict = @{}.mutableCopy;
//    [dict setValue:(nullable id) forKey:(nonnull NSString *)];
//    [dict setObject:(nonnull id) forKey:(nonnull id<NSCopying>)];
//    id _Nullable = [dict objectForKey:(nonnull id)];
//    id _Nullable = [dict valueForKey:(nonnull NSString *)];
}

@end
