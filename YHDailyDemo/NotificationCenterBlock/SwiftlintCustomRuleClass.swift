//
//  SwiftlintCustomRuleClass.swift
//  YHDailyDemo
//
//  Created by 杨虎 on 2021/8/9.
//  Copyright © 2021 杨虎. All rights reserved.
//

import UIKit

class SwiftlintCustomRuleClass: NSObject {
    // MARK : message
    var testVar = false
    
    // ABTestHelper.
    /// d +d ABTestHelper.  dd
    let hidden = "///ABTestHelper. my ninja can hide in the string"
    
    
    // ABTestHelper.
    func funcName(param: String) -> Bool {
        if param == "dd d ABTestHelper. ddd" {
            testVar = true
            return true
        }
        testVar = false
        return false
    }
}
