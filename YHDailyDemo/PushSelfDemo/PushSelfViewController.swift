//
//  PushSelfViewController.swift
//  YHDailyDemo
//
//  Created by 杨虎 on 2021/9/9.
//  Copyright © 2021 杨虎. All rights reserved.
//

import UIKit

@objc(YHPushSelfViewController)
public class PushSelfViewController: BaseWhiteBGColorViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // push 同一个实例控制器会 crash:
        // "<BaseNavigationController: 0x7f903781a400> is pushing the same view controller instance (<YHPushSelfViewController: 0x7f9036113330>) more than once which is not supported and is most likely an error in the application"
        
        //self.navigationController?.pushViewController(self, animated: true)
    }

}
