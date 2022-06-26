//
//  HitTestViewController.swift
//  YHDailyDemo
//
//  Created by 杨虎 on 2022/4/6.
//  Copyright © 2022 杨虎. All rights reserved.
//

import UIKit
import Foundation

//struct AStruct {
//    var str: NSMutableString
//    var number: Int
//}

@objc(YHHitTestViewController)
class HitTestViewController: BaseWhiteBGColorViewController {
    let queue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let hitView = HitTestView(frame: CGRect(x: 50, y: 200, width: 200, height: 300))
//        hitView.backgroundColor = UIColor.blue
//        view.addSubview(hitView)
        
        
//        let a = AStruct(str: NSMutableString(string: "test"), number: 0)
//        var b = a
//        b.number = 1
//        b.str = "change"
//        print("a = \(a)")
//        print("b = \(b)")

//        test()
    }
    
    func test() {
//        var mutableArray = [1,2,3,4,5,6,7,8,9,10]
//        for element in mutableArray {
//            print("one loop current = \(element)")
//            mutableArray.removeLast()
//        }
        queue.maxConcurrentOperationCount = 2
        for _ in 0..<4 {
            queue.addOperation {
                print("done")
            }
        }
    }
}
