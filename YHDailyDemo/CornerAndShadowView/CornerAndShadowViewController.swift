//
//  CornerAndShadowViewController.swift
//  YHDailyDemo
//
//  Created by 杨虎 on 2021/10/12.
//  Copyright © 2021 杨虎. All rights reserved.
//

import UIKit

@objc(YHCornerAndShadowViewController)
public class CornerAndShadowViewController: BaseWhiteBGColorViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()

        /// 既有圆角又有阴影的视图
        let v = UIView(frame: CGRect(x: 50, y: 150, width: 100, height: 100))
        v.backgroundColor = UIColor.blue
        view.addSubview(v)
        
        v.layer.shadowColor = UIColor.red.cgColor
        v.layer.shadowOpacity = 1.0
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize.zero
        v.layer.cornerRadius = 35
        
        let l = CALayer()
        l.masksToBounds = true
        l.frame = v.layer.bounds
        view.layer.addSublayer(l)
    }

}
