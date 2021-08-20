//
//  FlowLayout.swift
//  瀑布流
//
//

import UIKit

/// 瀑布流代理
@objc protocol FlowLayoutDataSource: class {
    
    /// ITEM 高度
    func flowLayoutHeight(_ layout: FlowLayout, indexPath: IndexPath) -> CGFloat
    
    /// 瀑布流列数，默认2列
    /// - Parameter layout: 布局
    /// - Returns: 列数
    @objc optional func numberOfColumnsInFlowLayout(_ layout: FlowLayout) -> Int
}

class FlowLayout: UICollectionViewFlowLayout {
    
    /// 瀑布流数据源代理
    weak var dataSource: FlowLayoutDataSource?
    
    /// 布局属性数组
    private lazy var attrsArray: [UICollectionViewLayoutAttributes] = []
    
    /// 每一列的高度累计
    private lazy var columnHeights: [CGFloat] = {
        let cols = self.dataSource?.numberOfColumnsInFlowLayout?(self) ?? 2
        var columnHeights = Array(repeating: self.sectionInset.top, count: cols)
        return columnHeights
    }()
    
    /// 最高的高度
    private var maxH: CGFloat = 0
    
    /// 索引
    private var startIndex = 0
}

extension FlowLayout {
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        let itemCount = collectionView.numberOfItems(inSection: 0)
        let cols = dataSource?.numberOfColumnsInFlowLayout?(self) ?? 2
        
        // Item宽度
        let itemW = (collectionView.bounds.width - self.sectionInset.left - self.sectionInset.right - self.minimumInteritemSpacing * CGFloat(cols - 1)) / CGFloat(cols)
        
        // 计算所有的item的属性
        for i in startIndex..<itemCount {
            // 设置每一个Item位置相关的属性
            let indexPath = IndexPath(item: i, section: 0)
            
            // 根据位置创建Attributes属性
            let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            // 获取CELL的高度
            guard let height = dataSource?.flowLayoutHeight(self, indexPath: indexPath) else {
                fatalError("请设置数据源,并且实现对应的数据源方法")
            }
            
            // 取出当前列所属的列索引
            let index = i % cols
            
            // 获取当前列的总高度
            var colH = columnHeights[index]
            
            // 将当前列的高度在加载当前ITEM的高度
            colH += height + minimumLineSpacing
            
            // 重新设置当前列的高度
            columnHeights[index] = colH
            
            // 5.设置item的属性
            attrs.frame = CGRect(x: self.sectionInset.left + (self.minimumInteritemSpacing + itemW) * CGFloat(index), y: colH - height - self.minimumLineSpacing, width: itemW, height: height)
            
            attrsArray.append(attrs)
        }
        
        // 4.记录最大值
        maxH = columnHeights.max() ?? 0
        
        // 5.给startIndex重新复制
        startIndex = itemCount
    }
}

extension FlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrsArray
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: 0, height: maxH + sectionInset.bottom - minimumLineSpacing)
    }
}
