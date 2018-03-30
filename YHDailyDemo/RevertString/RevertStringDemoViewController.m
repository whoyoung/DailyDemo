//
//  RevertStringDemoViewController.m
//  YHDailyDemo
//
//  Created by young on 2018/3/30.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import "RevertStringDemoViewController.h"

@interface RevertStringDemoViewController ()

@end

@implementation RevertStringDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"=======%@",[self revertStrBuffer:@"world"]);
}

- (NSString *)revertStrOC:(NSString *)str {
    NSString *tempStr = @"";
    for (NSUInteger i= str.length; i>0; i--) {
        tempStr = [tempStr stringByAppendingString:[str substringWithRange:NSMakeRange(i-1, 1)]];
    }
    return tempStr;
}

- (NSString *)revertStrBuffer:(NSString *)str {
    NSUInteger length = str.length;
    unichar *buffer = calloc(length, sizeof(unichar));
    [str getCharacters:buffer range:NSMakeRange(0, length-1)];
//    [str getCharacters:buffer range:[str rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, length-1)]];
    for (NSUInteger i=0; i<length/2; i++) {
        unichar temp = [str characterAtIndex:i];
        buffer[i] = [str characterAtIndex:length-i-1];
        buffer[length-i-1] = temp;

    }
    return [NSString stringWithCharacters:buffer length:length];
}

- (NSString *)revertStrCharacters:(NSString *)str {
    NSUInteger length = str.length;
    unichar characters[length];
    for (NSUInteger i=0; i<=length/2; i++) {
        unichar temp = [str characterAtIndex:i];
        characters[i] = [str characterAtIndex:length-i-1];
        characters[length-i-1] = temp;
    }
    return [NSString stringWithCharacters:characters length:length];
}

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
