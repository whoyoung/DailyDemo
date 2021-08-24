//
//  DemoSectionController.swift
//  YHDailyDemo
//
//  Created by 杨虎 on 2021/8/24.
//  Copyright © 2021 杨虎. All rights reserved.
//

import UIKit

class DemoSectionController: ListSectionController {
    private var obj: IGListModel?
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: UICollectionViewCell.self, for: self, at: index) else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = UIColor.randomColor()
        if let label = cell.viewWithTag(101) as? UILabel {
            label.text = obj?.title
            label.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        } else {
            let label = UILabel()
            label.text = obj?.title
            label.textColor = UIColor.black
            label.tag = 101
            cell.contentView.addSubview(label)
            label.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        }
        return cell
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 100)
    }
    
    override func didUpdate(to object: Any) {
        guard let o = object as? IGListModel else {
            return
        }
        obj = o
    }
}
