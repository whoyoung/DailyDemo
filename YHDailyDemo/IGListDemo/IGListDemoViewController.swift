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
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }()
    
    private lazy var datas: [IGListModel] = {
        var ds: [IGListModel] = []
        for i in 0..<200 {
            let m = IGListModel()
            m.title = "\(i)"
            ds.append(m)
        }
        return ds
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
        return datas
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
