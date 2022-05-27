//
//  ProtocolExtensionViewController.swift
//  YHDailyDemo
//
//  Created by young on 2022/5/26.
//  Copyright © 2022 杨虎. All rights reserved.
//

import UIKit

class Base:NSObject {
    var directProperty:String { return "This is Base" }
    var indirectProperty:String { return directProperty }
}

class Sub:Base { }

extension Sub {
//    Swift在extension 文档中说明，不能在extension中重载已经存在的方法
    // error tip: Non-@objc property 'directProperty' declared in 'Base' cannot be overridden from extension
    // var directProperty: String { return "This is Sub" }
}

protocol A {
    func a() -> Int
}
extension A {
    func a() -> Int {
        return 0
    }
}

// A class doesn't have implement of the function。
class B: A {}

class C: B {
    func a() -> Int {
        return 1
    }
}

// A class has implement of the function。
class D: A {
    func a() -> Int {
        return 1
    }
}

class E: D {
    override func a() -> Int {
        return 2
    }
}

@objc(YHProtocolExtensionViewController)
class ProtocolExtensionViewController: BaseWhiteBGColorViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        在Base.directProperty前添加dynamic关键字就可以获得”this is Sub”的结果。Swift在extension 文档中说明，不能在extension中重载已经存在的方法
        Base().directProperty // “This is Base”
        Sub().directProperty // “This is Sub”
        
        Base().indirectProperty // “This is Base”
        Sub().indirectProperty // expected "this is Sub"，but is “This is Base” <- Unexpected!
        
        
        
        print("B().a() = \(B().a())")
        print("C().a() = \(C().a())")
        print("(C() as A).a() = \((C() as A).a())")

        print("D().a() = \(D().a())")
        print("(D() as A).a() = \((D() as A).a())")
        print("E().a() = \(E().a())")
        print("(E() as A).a() = \((E() as A).a())")

        // 协议的拓展内实现的方法，无法被遵守协议类的子类重载。
//        B().a() = 0
//        C().a() = 1
//        (C() as A).a() = 0
//        D().a() = 1
//        (D() as A).a() = 1
//        E().a() = 2
//        (E() as A).a() = 2
    }
    
}
