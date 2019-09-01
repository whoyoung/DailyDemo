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

@interface CustomJsonModel : JSONModel

@property (nonatomic, copy) NSString *string; // attrs = "T@\"NSString\",C,N,V_string"

// error -- 此处会崩溃，因为 在 JSONValueTransformer 中，没有 JSONObjectFromNSAttributedString: 这个 selector
@property (nonatomic, strong) NSAttributedString *attrString; // (const char *) attrs = "T@\"NSAttributedString\",&,N,V_attrString"

@property (nonatomic, assign) int64_t int64Num; // (const char *) attrs = "Tq,N,V_int64Num" https://www.jianshu.com/p/cefa1da5e775

@end

NS_ASSUME_NONNULL_END
