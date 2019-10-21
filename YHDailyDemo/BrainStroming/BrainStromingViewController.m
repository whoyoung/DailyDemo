//
//  BrainStromingViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/6/4.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "BrainStromingViewController.h"
#import "YHTempViewController.h"
#import "YHTempModel.h"
#import "MyCollectionViewController.h"

@implementation BrainStromingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.datas addObjectsFromArray:[self rowDatas]];
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

- (void)blockVariable {
    typedef void(^myBlock)(void);
    
    int a = 1;
    __block int b = 1;
    
    myBlock block1 = ^(){
        NSLog(@"a==%d",a);
    };
    myBlock block2 = ^(){
        NSLog(@"b==%d",b);
    };
    
    a = 2;
    b = 2;
    
    
    myBlock block3 = ^(){
        NSLog(@"a==%d",a);
    };
    myBlock block4 = ^(){
        NSLog(@"b==%d",b);
    };
    
    block1();
    block2();
    block3();
    block4();
}

- (void)numberCount {
    NSUInteger digital = 504, num = 1;
    if (num > 9) {
        NSLog(@"%ld is not between 0 and 9",num);
    }
    NSUInteger count = 0, base = 1, round = digital;
    while (round > 0) {
        NSUInteger weight = round % 10;
        NSUInteger right = round / base;
        count += right * base;
        if (weight == num) {
            count += (digital % base) + 1;
        } else if (weight > num) {
            count += base;
        }
        base *= 10;
    }
    NSLog(@"digital = %ld, num = %ld, count = %ld",digital,num,count);
}

// 通过 setValue:forKey: 给基本数据类型的属性赋值，可以赋值成功。 推测，赋值过程有一个隐藏的类型转换过程
- (void)setValueForKey {
    YHTempModel *model = [[YHTempModel alloc] init];
    [model setValue:@"100" forKey:@"integer"]; // 可以正确赋值
    NSLog(@"model.integer = %ld",model.integer);
}

//2019-09-26 21:34:39.090 YHDailyDemo[5765:404336] all done
//2019-09-26 21:34:39.091 YHDailyDemo[5765:406851] 任务 1 完成，线程：<NSThread: 0x60800026a500>{number = 4, name = (null)}
//2019-09-26 21:34:39.092 YHDailyDemo[5765:406851] 任务 0 完成，线程：<NSThread: 0x60800026a500>{number = 4, name = (null)}
//2019-09-26 21:34:39.092 YHDailyDemo[5765:406851] 任务 2 完成，线程：<NSThread: 0x60800026a500>{number = 4, name = (null)}
- (void)dispatchApply {
    NSURLSession *session = [NSURLSession sharedSession];

    dispatch_apply(3, dispatch_get_global_queue(0, 0), ^(size_t idx) {
        NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:@"https://www.apple.com/ac/structured-data/images/knowledge_graph_logo.png?201810272230"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSLog(@"任务 %ld 完成，线程：%@", idx, [NSThread currentThread]);
                }];
        [task resume];
    });
    NSLog(@"all done");
}

//2019-09-26 21:33:36.918 YHDailyDemo[5765:406851] all done
//2019-09-26 21:33:36.919 YHDailyDemo[5765:406851] 任务完成，线程：<NSThread: 0x60800026a500>{number = 4, name = (null)}
- (void)dispatchGroup {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        [self startTask];
    });
    dispatch_group_notify(group, queue, ^{
        NSLog(@"all done");
    });
}
- (void)startTask {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:@"https://www.apple.com/ac/structured-data/images/knowledge_graph_logo.png?201810272230"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSLog(@"任务完成，线程：%@", [NSThread currentThread]);
            }];
    [task resume];
}

//2019-09-26 21:32:48.528 YHDailyDemo[5765:404387] 任务完成，线程：<NSThread: 0x60800026bbc0>{number = 3, name = (null)}
//2019-09-26 21:32:48.528 YHDailyDemo[5765:406851] all done
- (void)dispatchGroupEnterLeave {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:@"https://www.apple.com/ac/structured-data/images/knowledge_graph_logo.png?201810272230"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSLog(@"任务完成，线程：%@", [NSThread currentThread]);
                    dispatch_group_leave(group);
                }];
        [task resume];
    });
    dispatch_group_notify(group, queue, ^{
        NSLog(@"all done");
    });
}

//2019-09-26 21:45:28.050 YHDailyDemo[5845:419192] all done
//2019-09-26 21:45:28.102 YHDailyDemo[5845:419233] 任务完成，线程：<NSThread: 0x600000279140>{number = 3, name = (null)}
- (void)asyncOperation {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:@"https://www.apple.com/ac/structured-data/images/knowledge_graph_logo.png?201810272230"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSLog(@"任务完成，线程：%@", [NSThread currentThread]);
                }];
        [task resume];
    });
    NSLog(@"all done");
}

//2019-09-26 21:42:21.543 YHDailyDemo[5808:414525] 任务完成，线程：<NSThread: 0x600000279fc0>{number = 3, name = (null)}
//2019-09-26 21:42:21.544 YHDailyDemo[5808:414431] all done
- (void)semaphoreAsyncOperation {
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:@"https://www.apple.com/ac/structured-data/images/knowledge_graph_logo.png?201810272230"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSLog(@"任务完成，线程：%@", [NSThread currentThread]);
                    dispatch_semaphore_signal(sema);
                }];
        [task resume];
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    NSLog(@"all done");
}

- (void)addAutoReleasePool {
    NSString *string;
    @autoreleasepool {
//        string = @"string";
        string = [NSString stringWithFormat:@"format string"];
        NSLog(@"in string = %@",string);
    }
    NSLog(@"string = %@",string);
}


- (void)forIMemory {
    for (NSUInteger i = 0; i < 60000; i++) {
        // 以下注释掉的方法不会导致内存累积过多
//        NSString *firstString = @"first string; ";
//        NSString *secondString = @"second string";
//        NSString *string = [firstString stringByAppendingString:secondString];
//        NSLog(@"for i = %ld, string = %@",i,string);
//
//        NSObject *obj1 = [[NSObject alloc] init];
//        NSObject *obj2 = [[NSObject alloc] init];
//        NSObject *obj3 = [[NSObject alloc] init];
//        NSLog(@"for i = %ld, obj1 = %p, obj2 = %p, obj3 = %p",i,obj1,obj2,obj3);
//
//        NSUInteger value1 = 1;
//        NSUInteger value2 = 2;
//        NSUInteger value3 = 3;
//        NSLog(@"for i = %ld, value1 = %ld, value2 = %ld, value3 = %ld",i,value1,value2,value3);
        
        NSString *anotherStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://www.jianshu.com/p/9da2929c9b61"] encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"anotherStr = %p",anotherStr);
    }
}

// 苹果官方文档：Use Local Autorelease Pool Blocks to Reduce Peak Memory Footprint https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmAutoreleasePools.html
- (void)forIAutoReleasePoolMemory {
    for (NSUInteger i = 0; i < 60000; i++) {
        @autoreleasepool {
//            NSString *firstString = @"first string; ";
//            NSString *secondString = @"second string";
//            NSString *string = [firstString stringByAppendingString:secondString];
//            NSLog(@"for i = %ld, string = %@",i,string);
//
//            NSObject *obj1 = [[NSObject alloc] init];
//            NSObject *obj2 = [[NSObject alloc] init];
//            NSObject *obj3 = [[NSObject alloc] init];
//            NSLog(@"for i = %ld, obj1 = %p, obj2 = %p, obj3 = %p",i,obj1,obj2,obj3);
//
//            NSUInteger value1 = 1;
//            NSUInteger value2 = 2;
//            NSUInteger value3 = 3;
//            NSLog(@"for i = %ld, value1 = %ld, value2 = %ld, value3 = %ld",i,value1,value2,value3);
            
            NSString *anotherStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://www.jianshu.com/p/9da2929c9b61"] encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"anotherStr = %p",anotherStr);
        }
        
    }
}

- (void)toCollectionVC {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 30;
    layout.itemSize = CGSizeMake(100, 40);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    MyCollectionViewController *vc = [[MyCollectionViewController alloc] initWithCollectionViewLayout:layout];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSArray *)rowDatas {
    return @[
        @"toCollectionVC",@"forIAutoReleasePoolMemory",@"forIMemory",@"addAutoReleasePool",@"asyncOperation",@"semaphoreAsyncOperation",@"dispatchGroupEnterLeave",@"dispatchGroup",@"dispatchApply",@"decoderUTF8String",@"decodeBase64Str",@"arrayToDict",@"sendMessageToNil",@"topController",@"postNotification",@"toTempViewController",@"keyValueType",@"blockVariable",@"numberCount",@"setValueForKey"
    ];
}

@end
