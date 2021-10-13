//
//  FlowLayout.swift
//  瀑布流
//
//

import UIKit

/// 瀑布流代理
@objc public protocol FlowLayoutDataSource: AnyObject {
    /// ITEM 高度
    func flowLayoutHeight(_ layout: FlowLayout, indexPath: IndexPath) -> CGFloat
    
    /// 瀑布流列数，默认2列
    /// - Parameter layout: 布局
    /// - Returns: 列数
    @objc optional func numberOfColumnsInFlowLayout(_ layout: FlowLayout) -> Int
    
    /// item 的总数，默认为 collectionView.numberOfItems(inSection: 0)
    /// 自定义实现获取 item 总数的方法。
    @objc optional func numberOfItemsInFlowLayout(_ layout: FlowLayout) -> Int
}

public class FlowLayout: UICollectionViewFlowLayout {
    
    /// 瀑布流数据源代理
    public weak var dataSource: FlowLayoutDataSource?
    
    /// 布局属性数组
    private lazy var attrsArray: [UICollectionViewLayoutAttributes] = []
    
    /// 每一列的高度累计
    private var columnHeights: [CGFloat] = []
    
    /// 最高的高度
    private var maxH: CGFloat = 0
    
    /// 智能排序: item 拼接在高度最小的列。默认为 true。 false: 按顺序左右逐个排列
    public var smartSort = true
    
    private var existedNum = 0
}

extension FlowLayout {
    
    public override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        if columnHeights.isEmpty {
            let columns = self.dataSource?.numberOfColumnsInFlowLayout?(self) ?? 2
            columnHeights = Array(repeating: self.sectionInset.top, count: columns)
        }
        
        var itemCount = collectionView.numberOfItems(inSection: 0)
        if let number = dataSource?.numberOfItemsInFlowLayout?(self) {
            itemCount = number
        }
        let cols = dataSource?.numberOfColumnsInFlowLayout?(self) ?? 2
        
        let drawW = collectionView.bounds.width - self.sectionInset.left - self.sectionInset.right
        // Item宽度
        let itemW = (drawW - self.minimumInteritemSpacing * CGFloat(cols - 1)) / CGFloat(cols)
        
        // 计算所有的item的属性
        for i in existedNum..<itemCount {
            let indexPath = IndexPath(item: i, section: 0)
            let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            // 获取CELL的高度
            guard let height = dataSource?.flowLayoutHeight(self, indexPath: indexPath) else {
                fatalError("请设置数据源,并且实现对应的数据源方法")
            }
            
            var destColumn = i % cols
            var minHeight = columnHeights[destColumn]
            if smartSort {
                // swiftlint:disable for_where
                for idx in 0..<columnHeights.count {
                    if minHeight > columnHeights[idx] {
                        minHeight = columnHeights[idx]
                        destColumn = idx
                    }
                }
                // swiftlint:enable for_where
            }
            
            let x = self.sectionInset.left + (self.minimumInteritemSpacing + itemW) * CGFloat(destColumn)
 
            // 设置item的属性
            attrs.frame = CGRect(x: x, y: minHeight, width: itemW, height: height)
            // 将当前列的高度在加载当前ITEM的高度
            minHeight += height + minimumLineSpacing
            // 重新设置当前列的高度
            columnHeights[destColumn] = minHeight
            
            attrsArray.append(attrs)
        }
        existedNum = itemCount
        maxH = columnHeights.max() ?? 0
    }
    
    public override func invalidateLayout() {
        super.invalidateLayout()
        columnHeights.removeAll()
        existedNum = 0
        attrsArray.removeAll()
    }
}

extension FlowLayout {
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrsArray
    }
    
    public override var collectionViewContentSize: CGSize {
        return CGSize(width: 0, height: maxH + sectionInset.bottom - minimumLineSpacing)
    }
}
