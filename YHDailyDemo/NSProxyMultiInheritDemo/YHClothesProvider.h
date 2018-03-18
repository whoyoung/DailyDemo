//
//  YHClothesProvider.h
//  YHDailyDemo
//
//  Created by young on 2018/3/18.
//  Copyright © 2018年 杨虎. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol YHClothesProviderProtocol<NSObject>
- (void)purchaseClothes;
@end
@interface YHClothesProvider : NSObject <YHClothesProviderProtocol>

@end
