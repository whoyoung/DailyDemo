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
    var identifier = false
    
    // ABTestHelper.
    /// d +d ABTestHelper.  dd
    let hidden = "string"
    
    
    // ABTestHelper.
    func funcName(param: String) -> Bool {
        if param == "string" {
            identifier = true
            return true
        }
        identifier = false
        return false
    }
    
    func funcInvoke() {
        let result = funcName(param: "argument")
        print("\(result)")
    }
}
