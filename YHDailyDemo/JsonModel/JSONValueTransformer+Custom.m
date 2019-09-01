//
//  JSONValueTransformer+Custom.m
//  YHDailyDemo
//
//  Created by young on 2019/9/1.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "JSONValueTransformer+Custom.h"

@implementation JSONValueTransformer (Custom)

- (NSDictionary *)JSONObjectFromNSAttributedString:(NSAttributedString *)attrString {
    NSDictionary<NSAttributedStringKey, id> *dict = [attrString attributesAtIndex:0 effectiveRange:nil];
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSAttributedStringKey  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        /*
         obj 的类型太多了，想都转转成 NSDictionary 太难了， 所以放弃了。。。。。
         */
    }];
    return mutDict;
}

@end
