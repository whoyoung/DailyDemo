//
//  ViewController.m
//  OCDemo
//
//  Created by young on 2022/6/17.
//

#import "ViewController.h"
#import "DemoView.h"
#import "NextViewController.h"
#import "FollowStatusSyncManager.h"


@interface ViewController ()

//@property (nonatomic, strong) NSArray *strongA;
//
//@property (nonatomic, copy) NSArray *arrayCopy;
//
//@property (nonatomic, strong) NSMutableArray *mutaA;

@property (nonatomic, strong) FollowStatusSyncPlugin *plugin;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];
    _plugin = [FollowStatusSyncPlugin new];
    __weak typeof(self) weakSelf = self;
    _plugin.block = ^(FollowStatusSync * _Nonnull status) {
        weakSelf.view.backgroundColor = [UIColor redColor];
        NSLog(@"first page = %lu", (unsigned long)status.status);
    };
    
    [[FollowStatusSyncManager shareManager] registerPlugin:_plugin];
    
//    [self addDemoView];
    
//    [self seriaQueueTest];
    
//    [self concurrentQueueTest];
    
//    NSMutableArray *test = [NSMutableArray arrayWithObject:@1];
//    self.strongA = test;
//    self.arrayCopy = test;
//    self.mutaA = test;
//
//    NSString *before = [NSString stringWithFormat:@"strongA = %@, %p; arrayCopy = %@, %p; mutaA = %@, %p;\n", self.strongA, self.strongA, self.arrayCopy, self.arrayCopy, self.mutaA, self.mutaA];
//    NSLog(@"%@",before);
//
//    [test addObject:@2];
//    NSString *after = [NSString stringWithFormat:@"strongA = %@, %p; arrayCopy = %@, %p; mutaA = %@, %p;\n", self.strongA, self.strongA, self.arrayCopy, self.arrayCopy, self.mutaA, self.mutaA];
//    NSLog(@"%@",after);
//
//    [self.mutaA addObject:@3];
//    NSString *again = [NSString stringWithFormat:@"strongA = %@, %p; arrayCopy = %@, %p; mutaA = %@, %p;", self.strongA, self.strongA, self.arrayCopy, self.arrayCopy, self.mutaA, self.mutaA];
//    NSLog(@"%@",again);
    
//    NSLog()
    
//    __weak NSObject *temp = nil;
//    {
//        NSObject *obj = [NSObject new];
//        temp = obj;
//        NSLog([NSString stringWithFormat:@"%@", temp]);
//    }
//    NSLog([NSString stringWithFormat:@"%@", (temp == nil ? @"nil" : temp)]);

}

- (void)seriaQueueTest {
    NSLog(@"1");
    dispatch_queue_t seriaQ = dispatch_queue_create("yhSeria", DISPATCH_QUEUE_SERIAL);
    dispatch_async(seriaQ, ^{
        NSLog(@"2，%@",[NSThread currentThread]);
        dispatch_async(seriaQ, ^{
            NSLog(@"3，%@",[NSThread currentThread]);
        });
        dispatch_async(seriaQ, ^{
            NSLog(@"5，%@",[NSThread currentThread]);
        });
//        dispatch_sync(seriaQ, ^{ // 会阻塞线程崩溃
//            NSLog(@"4");
//            sleep(2);
//        });
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{ // 阻塞当前线程，在global_queue执行完此 block 之后，才执行异步任务
            sleep(5);
            NSLog(@"4，%@",[NSThread currentThread]);
        });
//        dispatch_async(dispatch_get_main_queue(), ^{ // block 加入主队列执行
//            sleep(5);
//            NSLog(@"4");
//        });
//        dispatch_sync(dispatch_get_main_queue(), ^{ // 阻塞当前线程，在主队列执行完此 block 之后，才执行异步任务
//            sleep(5);
//            NSLog(@"4，%@",[NSThread currentThread]);
//        });
        
        dispatch_async(seriaQ, ^{
            NSLog(@"6，%@",[NSThread currentThread]);
        });
        dispatch_async(seriaQ, ^{
            NSLog(@"7，%@",[NSThread currentThread]);
        });
        NSLog(@"seriaQ end，%@",[NSThread currentThread]);
    });
    NSLog(@"end");
}

- (void)concurrentQueueTest {
    NSLog(@"1");
    dispatch_queue_t curQ = dispatch_queue_create("yhConcurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(curQ, ^{
        NSLog(@"2，%@",[NSThread currentThread]);
        dispatch_async(curQ, ^{
            NSLog(@"3，%@",[NSThread currentThread]);
        });
        dispatch_async(curQ, ^{
            NSLog(@"5，%@",[NSThread currentThread]);
        });
//        dispatch_sync(curQ, ^{ // 会阻塞线程，当前 block 执行完后，才继续往下执行
//            sleep(5);
//            NSLog(@"4，%@",[NSThread currentThread]);
//        });
//        dispatch_sync(dispatch_get_global_queue(0, 0), ^{ // 阻塞当前线程，在global_queue执行完此 block 之后，才继续往下执行任务
//            sleep(5);
//            NSLog(@"4，%@",[NSThread currentThread]);
//        });
//        dispatch_async(dispatch_get_main_queue(), ^{ // block 加入主队列执行
//            sleep(5);
//            NSLog(@"4，%@",[NSThread currentThread]);
//        });
        dispatch_sync(dispatch_get_main_queue(), ^{ // 阻塞当前线程，在主队列执行完此 block 之后，才继续往下执行任务
            sleep(5);
            NSLog(@"4，%@",[NSThread currentThread]);
        });
        
        dispatch_async(curQ, ^{
            NSLog(@"6，%@",[NSThread currentThread]);
        });
        dispatch_async(curQ, ^{
            NSLog(@"7，%@",[NSThread currentThread]);
        });
        NSLog(@"curQ end，%@",[NSThread currentThread]);
    });
    NSLog(@"end");
}

- (void)addDemoView {
    UIView *demoV = [[DemoView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    demoV.backgroundColor = [UIColor redColor];
    [self.view addSubview:demoV];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:UpdateUINotificationName object:nil];
}

- (void)updateUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *demoV = self.view.subviews.lastObject;
        if (demoV) {
            NSLog(@"current thread is main = %d", [NSThread isMainThread]);
            demoV.backgroundColor = [UIColor greenColor];
        }
    });
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"vc touchesBegan");
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    NSLog(@"vc touchesEnded");
    UIViewController *vc = [NextViewController new];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"vc touchesCancelled");
}

//- hittest

@end
