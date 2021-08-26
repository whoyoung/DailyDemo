//
//  IGListDemoViewController.swift
//  YHDailyDemo
//
//  Created by 杨虎 on 2021/8/24.
//  Copyright © 2021 杨虎. All rights reserved.
//

import UIKit

@objc(YHIGListDemoViewController)
public class IGListDemoViewController: BaseWhiteBGColorViewController {

    private lazy var collectionView: UICollectionView = {
        let layout = FlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.dataSource = self
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }()
    
    private lazy var datas: IGListModels = {
        var ds: [IGListModel] = []
        for i in 0..<200 {
            let m = IGListModel()
            m.title = "\(i)"
            ds.append(m)
        }
        let ms = IGListModels()
        ms.models = ds
        return ms
    }()
    
    private lazy var adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 2)
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        adapter.delegate = self

    }
    
    public override func viewDidLayoutSubviews() {
        collectionView.frame = view.bounds
    }

}

extension IGListDemoViewController: ListAdapterDataSource {
    public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [datas]
    }
    
    public func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return DemoSectionController()
    }
    
    public func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
}

extension IGListDemoViewController: ListAdapterDelegate {
    public func listAdapter(_ listAdapter: ListAdapter, willDisplay object: Any, at index: Int) {
        
    }
    
    public func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying object: Any, at index: Int) {
        
    }
    
}

extension IGListDemoViewController: UIScrollViewDelegate {
    
}

extension IGListDemoViewController: FlowLayoutDataSource {
    func flowLayoutHeight(_ layout: FlowLayout, indexPath: IndexPath) -> CGFloat {
        let model = datas.models[indexPath.item]
        if model.size != CGSize.zero {
            return model.size.height
        }
        let w = (view.bounds.width - 10) / 2.0
        let s = CGSize(width: w, height: CGFloat(arc4random_uniform(100)) + 100)
        model.size = s
        return s.height 
    }
    
    func numberOfColumnsInFlowLayout(_ layout: FlowLayout) -> Int {
        return 2
    }

}
