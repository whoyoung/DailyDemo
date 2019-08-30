//
//  CustomJsonModel.h
//  YHDailyDemo
//
//  Created by 杨虎 on 2019/8/30.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel/JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CustomJsonModel : NSObject

@property (nonatomic, copy) NSString *string;

@property (nonatomic, strong) NSAttributedString *attrString;

@end

NS_ASSUME_NONNULL_END
