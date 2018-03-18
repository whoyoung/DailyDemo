//
//  YHMultiInheritProxy.h
//  YHDailyDemo
//
//  Created by young on 2018/3/18.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHBookProvider.h"
#import "YHClothesProvider.h"

@interface YHMultiInheritProxy : NSProxy  <YHBookProviderProtocol,YHClothesProviderProtocol>
+ (instancetype)purchase;
@end
