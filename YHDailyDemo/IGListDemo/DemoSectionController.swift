//
//  DemoSectionController.swift
//  YHDailyDemo
//
//  Created by 杨虎 on 2021/8/24.
//  Copyright © 2021 杨虎. All rights reserved.
//

import UIKit

class DemoSectionController: ListSectionController {
    private var obj: IGListModels?
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: UICollectionViewCell.self, for: self, at: index) else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = UIColor.randomColor()
        if let label = cell.viewWithTag(101) as? UILabel {
            label.text = obj?.models[index].title
            label.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        } else {
            let label = UILabel()
            label.text = obj?.models[index].title
            label.textColor = UIColor.black
            label.tag = 101
            cell.contentView.addSubview(label)
            label.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        }
        return cell
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let context = collectionContext else { return CGSize.zero }
        let model = obj?.models[index]
        if let size = model?.size, size != CGSize.zero {
            return size
        }
        let w = (context.containerSize.width - minimumInteritemSpacing - context.containerInset.left - context.containerInset.right) / 2.0
        let s = CGSize(width: w, height: CGFloat(arc4random_uniform(100)) + 100)
        model?.size = s
        return s
    }
    
    override func numberOfItems() -> Int {
        return obj?.models.count ?? 0
    }
    
    override func didUpdate(to object: Any) {
        guard let o = object as? IGListModels else {
            return
        }
        obj = o
    }
}
