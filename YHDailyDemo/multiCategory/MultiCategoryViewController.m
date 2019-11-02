//
//  MultiCategoryViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/4/5.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "MultiCategoryViewController.h"
#import "NSString+append.h"
@interface MultiCategoryViewController ()

@end

@implementation MultiCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSString *strDD = @"dd";
    NSString *str = [@"dd" stringByWhoyoung]; //调用原类不存在的方法，需要引入分类的头文件

#warning 这个方法会导致 App 启动时崩溃，神奇。。。。
    //    NSString *subStr = [@"dd" substringFromIndex:0]; //调用原类存在的方法，不要需要引入分类的头文件
    
    //多个分类重写同一个方法，具体调用哪个分类的方法，与分类在build phase--compile source中分类的顺序相关
//    NSLog(@"str ==== %@, subStr=====%@",str,subStr);
}

//
//*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Non-conforming methods on protocol 'UISApplicationSupportXPCServerInterface':(
//    "requestPasscodeUnlockUIWithCompletion: (null): synchronous method has invalid return type",
//    "requestPasscodeUnlockUIWithCompletion: requestPasscodeUnlockUIWithCompletion: a method with a return value may not also provide a block",
//    "requestPasscodeUnlockUIWithCompletion: (null): Method cannot have both a sync and async return value"
//)'
//*** First throw call stack:
//(
//    0   CoreFoundation                      0x00007fff23b98bde __exceptionPreprocess + 350
//    1   libobjc.A.dylib                     0x00007fff503b5b20 objc_exception_throw + 48
//    2   CoreFoundation                      0x00007fff23b98958 +[NSException raise:format:arguments:] + 88
//    3   Foundation                          0x00007fff255eb7be -[NSAssertionHandler handleFailureInFunction:file:lineNumber:description:] + 166
//    4   BoardServices                       0x00007fff2fd86e5b __vetProtocol + 3514
//    5   BoardServices                       0x00007fff2fd879b8 -[BSMutableServiceInterface setServer:] + 138
//    6   UIKitServices                       0x00007fff478612db -[UISApplicationSupportClient _remoteTarget] + 167
//    7   UIKitServices                       0x00007fff47860b89 -[UISApplicationSupportClient applicationInitializationContext] + 153
//    8   UIKitCore                           0x00007fff46dcff5d __63-[_UIApplicationConfigurationLoader _loadInitializationContext]_block_invoke_2 + 344
//    9   UIKitCore                           0x00007fff46dcfe03 __UIAPPLICATION_IS_LOADING_INITIALIZATION_INFO_FROM_THE_SYSTEM__ + 12
//    10  UIKitCore                           0x00007fff46dcfdf1 __63-[_UIApplicationConfigurationLoader _loadInitializationContext]_block_invoke + 69
//    11  libdispatch.dylib                   0x00000001050bfd64 _dispatch_client_callout + 8
//    12  libdispatch.dylib                   0x00000001050c12b3 _dispatch_once_callout + 66
//    13  UIKitCore                           0x00007fff46dcfdaa -[_UIApplicationConfigurationLoader _loadInitializationContext] + 103
//    14  UIKitCore                           0x00007fff46dd009b __70-[_UIApplicationConfigurationLoader startPreloadInitializationContext]_block_invoke + 21
//    15  libdispatch.dylib                   0x00000001050bedf0 _dispatch_call_block_and_release + 12
//    16  libdispatch.dylib                   0x00000001050bfd64 _dispatch_client_callout + 8
//    17  libdispatch.dylib                   0x00000001050d146e _dispatch_root_queue_drain + 819
//    18  libdispatch.dylib                   0x00000001050d1ba4 _dispatch_worker_thread2 + 132
//    19  libsystem_pthread.dylib             0x00007fff5141c6b3 _pthread_wqthread + 583
//    20  libsystem_pthread.dylib             0x00007fff5141c3fd start_wqthread + 13
//)

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
