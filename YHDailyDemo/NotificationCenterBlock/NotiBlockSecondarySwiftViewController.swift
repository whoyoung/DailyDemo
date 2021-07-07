//
//  NotiBlockSecondarySwiftViewController.swift
//  YHDailyDemo
//
//  Created by 杨虎 on 2021/7/7.
//  Copyright © 2021 杨虎. All rights reserved.
//

import UIKit

@objc public class NotiBlockSecondarySwiftViewController: BaseWhiteBGColorViewController {

    private var notiObserver: NSObjectProtocol?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        notiObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name("SendNotiBlockNotification"), object: nil, queue: .main, using: { [weak self] _ in
            self?.view.backgroundColor = UIColor.red
        })
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        NotificationCenter.default.post(name: NSNotification.Name("SendNotiBlockNotification"), object: nil)
    }
    
    deinit {
        if let obs = notiObserver {
            NotificationCenter.default.removeObserver(obs)
        }
        debugPrint("NotiBlockSecondarySwiftViewController deinit")
    }
}
