//
//  JSONValueTransformer+Custom.h
//  YHDailyDemo
//
//  Created by young on 2019/9/1.
//  Copyright © 2019 杨虎. All rights reserved.
//

#import "JSONValueTransformer.h"

NS_ASSUME_NONNULL_BEGIN

@interface JSONValueTransformer (Custom)

/**
 * Transforms a set to an array
 * @param attrString incoming attrString
 * @return a dictionary with the attrString's elements
 */
- (NSDictionary *)JSONObjectFromNSAttributedString:(NSAttributedString *)attrString;


@end

NS_ASSUME_NONNULL_END
