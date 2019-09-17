//
//  AlgorithmViewController.m
//  YHDailyDemo
//
//  Created by young on 2019/9/16.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "AlgorithmViewController.h"

@interface AlgorithmViewController ()

@end

@implementation AlgorithmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.datas addObjectsFromArray:@[
                                      @"kMaxValueInArray",@"maxNoDuplicateCharLength",@"twoNumberEqualTarget",@"maxReverseString"
                                      ]];
}

/**
 数组中的第K个最大元素
 */
- (void)kMaxValueInArray {
    NSArray *array = @[@7,@8,@9,@2,@8,@10,@7,@4,@34,@12,@56];
    NSUInteger k = 9;
    
    NSMutableArray *temp = [NSMutableArray array];
    for (NSUInteger i=0; i<array.count; i++) {
        if (temp.count == k) {
            for (NSUInteger j = k; j>0; j--) {
                if ([temp[j-1] integerValue] >= [array[i] integerValue]) {
                    [temp insertObject:array[i] atIndex:j];
                    [temp removeLastObject];
                    break;
                } else if (j == 1) {
                    [temp insertObject:array[i] atIndex:0];
                    [temp removeLastObject];
                }
            }
        } else {
            NSUInteger count = temp.count;
            if (count == 0) {
                [temp addObject:array[i]];
                continue;
            }
            for (NSUInteger j = count; j>0; j--) {
                if ([temp[j-1] integerValue] >= [array[i] integerValue]) {
                    [temp insertObject:array[i] atIndex:j];
                    break;
                } else if (j == 1) {
                    [temp insertObject:array[i] atIndex:0];
                }
            }
        }
    }
    NSLog(@"k values = %@",[temp lastObject]);
}

/**
 前 K 个高频元素
 */
- (void)zero2KFrequencyInArray {
    
}

/**
 最长回文子串:给定一个字符串 s，找到 s 中最长的回文子串。你可以假设 s 的最大长度为 1000。
 
 输入: "babad"
 输出: "bab"
 注意: "aba" 也是一个有效答案。
 */
- (void)maxReverseString {
    NSString *str = @"babbuhwbebwhbc";
    
    NSUInteger start = 0, end = 0;
    for (NSUInteger i = 0; i < str.length; i++) {
        NSUInteger left = [self expandAround:str left:i right:i];
        NSUInteger right = [self expandAround:str left:i right:i+1];
        NSUInteger max = MAX(left, right);
        if (max > (end - start)) {
            start = i - (max - 1) / 2;
            end = i + max / 2;
        }
    }
    if (end - start == 0) {
        NSLog(@"maxReverseString = null");
    } else {
        NSLog(@"maxReverseString = %@",[str substringWithRange:NSMakeRange(start, end - start + 1)]);
    }
}

- (NSUInteger)expandAround:(NSString *)str left:(NSUInteger)left right:(NSUInteger)right {
    while (left >= 0 && right < str.length && [[str substringWithRange:NSMakeRange(left, 1)] isEqualToString:[str substringWithRange:NSMakeRange(right, 1)]]) {
        left--;
        right++;
    }
    if (right - left > 0) {
        return right - left - 1;
    }
    return 0;
}

/**
 无重复字符的最长子串 : 给定一个字符串，请你找出其中不含有重复字符的 最长子串 的长度。
 输入: "pwdhgpkew"
 输出: 7
 解释: 因为无重复字符的最长子串是 "wdhgpke"，所以其长度为 7。
 */
- (void)maxNoDuplicateCharLength {
    NSString *str = @"pwdhgpkew";
    
    NSUInteger length = 0, i=0, j=0;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (; j < str.length; j++) {
        NSString *jChar = [str substringWithRange:NSMakeRange(j, 1)];
        NSNumber *idx = [dict objectForKey:jChar];
        if (idx) {
            length = MAX(j - i, length);
            i = idx.integerValue + 1;
        }
        [dict setObject:@(j) forKey:jChar];
    }
    NSLog(@"length = %ld",length);
}

/**
 两数之和 : 给定一个整数数组 nums 和一个目标值 target，请你在该数组中找出和为目标值的那 两个 整数，并返回他们的数组下标。
 你可以假设每种输入只会对应一个答案。但是，你不能重复利用这个数组中同样的元素。
 给定 nums = [2, 7, 11, 15], target = 9
 
 因为 nums[0] + nums[1] = 2 + 7 = 9
 所以返回 [0, 1]
 */
- (void)twoNumberEqualTarget {
    NSArray *array = @[@2,@7,@11,@15];
    NSUInteger target = 9;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSUInteger i=0; i<array.count; i++) {
        NSNumber *key = @(target - [array[i] integerValue]);
        NSNumber *idx = [dict objectForKey:key];
        if (idx) {
            NSLog(@"idex = %ld,%ld",idx.integerValue,i);
            break;
        } else {
            [dict setObject:@(i) forKey:array[i]];
        }
    }
}

@end
