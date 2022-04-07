//
//  HitTestView.swift
//  YHDailyDemo
//
//  Created by 杨虎 on 2022/4/6.
//  Copyright © 2022 杨虎. All rights reserved.
//

import UIKit

class HitTestView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let label = UILabel(frame: CGRect(x: 20, y: 20, width: 100, height: 100))
        label.backgroundColor = UIColor.red
        label.text = "label"
        label.textColor = UIColor.black
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
       let v = super.hitTest(point, with: event)
        if let _ = v {
            // 一次点击事件，hitTest方法会被系统调用 2 次
            debugPrint("hitTest ======")
        }
       return v
    }

}
