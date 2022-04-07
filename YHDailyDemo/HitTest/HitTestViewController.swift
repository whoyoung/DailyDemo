//
//  HitTestViewController.swift
//  YHDailyDemo
//
//  Created by 杨虎 on 2022/4/6.
//  Copyright © 2022 杨虎. All rights reserved.
//

import UIKit

@objc(YHHitTestViewController)
class HitTestViewController: BaseWhiteBGColorViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let hitView = HitTestView(frame: CGRect(x: 50, y: 200, width: 200, height: 300))
        hitView.backgroundColor = UIColor.blue
        view.addSubview(hitView)
    }
    
}
