//
//  YHBookProvider.h
//  YHDailyDemo
//
//  Created by young on 2018/3/18.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol YHBookProviderProtocol<NSObject>
- (void)purchaseBook;
@end
@interface YHBookProvider : NSObject <YHBookProviderProtocol>

@end
