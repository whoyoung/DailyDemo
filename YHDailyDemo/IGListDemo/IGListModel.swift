//
//  IGListModel.swift
//  YHDailyDemo
//
//  Created by 杨虎 on 2021/8/24.
//  Copyright © 2021 杨虎. All rights reserved.
//

import UIKit

class IGListModel: NSObject, ListDiffable {
    
    public var title = ""
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? IGListModel {
            return self == object
        }
        return false
    }
}
