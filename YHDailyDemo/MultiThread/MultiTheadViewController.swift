//
//  MultiTheadViewController.swift
//  YHDailyDemo
//
//  Created by young on 2022/4/22.
//  Copyright © 2022 杨虎. All rights reserved.
//

import UIKit

@objc(YHMultiTheadViewController)
class MultiTheadViewController: BaseWhiteBGColorViewController {
    
    let operationQ: OperationQueue = {
        let opQ = OperationQueue()
        opQ.maxConcurrentOperationCount = -1
        return opQ
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        operationDemo()
    }
    
    func operationDemo() {
        let op1 = createOperation(name: "operation 1")
        let op2 = createOperation(name: "operation 2")
        operationQ.addOperation(op1)
        operationQ.addOperation(op2)
        if #available(iOS 13.0, *) {
            operationQ.addBarrierBlock {
                print("operation barrier execution")
            }
        }
    }
    /*
     结论：
     1. OperationQueue 里的 operation 执行完 block 里的代码，就算执行完毕了，不会等待 block 里异步执行的代码的执行结果
     2. OperationQueue 的 cancelAllOperations 只会取消未执行的 operation。已执行的 operation block 里的异步执行的代码不会随着 cancelAllOperations 调用而停止执行。
    */
    func createOperation(name: String) -> BlockOperation {
        let blockOp = BlockOperation {
            print("operation \(name) execution")
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 5, execute: DispatchWorkItem(block: {
                print("operation \(name) asyncAfter execution")
            }))
        }
        return blockOp
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        operationQ.cancelAllOperations()
        operationDemo()
    }

}
