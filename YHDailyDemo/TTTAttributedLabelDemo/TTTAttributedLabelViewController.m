//
//  TTTAttributedLabelViewController.m
//  YHDailyDemo
//
//  Created by 杨虎 on 2020/4/24.
//  Copyright © 2020 杨虎. All rights reserved.
//

#import "TTTAttributedLabelViewController.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface TTTAttributedLabelViewController () <TTTAttributedLabelDelegate>

@end

@implementation TTTAttributedLabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    TTTAttributedLabel *attributedLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(40, 100, 200, 200)];

    NSString *originStr = @"Tom Bombadil https://www.baidu.com 多大的 13261965795 aaaasd dsssssss ssssssssssffwwewefafasfds";
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:originStr
                                                                    attributes:@{
            (id)kCTForegroundColorAttributeName : (id)[UIColor redColor].CGColor,
            NSFontAttributeName : [UIFont boldSystemFontOfSize:16],
            NSKernAttributeName : [NSNull null],
            (id)kTTTBackgroundFillColorAttributeName : (id)[UIColor greenColor].CGColor
    }];
    attributedLabel.enabledTextCheckingTypes = NSTextCheckingAllTypes;
    // The attributed string is directly set, without inheriting any other text
    // properties of the label.
    attributedLabel.text = attString;
    attributedLabel.numberOfLines = 4;
    attributedLabel.attributedTruncationToken = truncationAttributedString();
    NSRange range = [originStr rangeOfString:@"Tom"];
    [attributedLabel addLinkToURL:[NSURL URLWithString:@"https://www.baidu.com"] withRange:range];
    attributedLabel.delegate = self;
    [self.view addSubview:attributedLabel];
}

static NSAttributedString *truncationAttributedString() {
  NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:@"..."
                                         attributes:@{
                                             NSFontAttributeName : [UIFont systemFontOfSize:14],
                                             NSForegroundColorAttributeName : [UIColor redColor],
                                             NSLinkAttributeName : [NSURL URLWithString:@"https://www.google.com"]
                                         }];
    [attributedStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"查看全部" attributes:@{
        NSFontAttributeName : [UIFont systemFontOfSize:18],
        NSForegroundColorAttributeName : [UIColor blueColor],
    }]];
    return attributedStr.copy;
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    NSMutableString* str=[[NSMutableString alloc] initWithFormat:@"tel:%@",phoneNumber];

    UIWebView * callWebview = [[UIWebView alloc] init];

    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];

    [self.view addSubview:callWebview];
}

@end
