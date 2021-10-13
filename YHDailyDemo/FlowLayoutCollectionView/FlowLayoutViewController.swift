//
//  FlowLayoutViewController.swift

import UIKit

@objc(YHFlowLayoutViewController)
public class FlowLayoutViewController: UIViewController {
    private let kContentCellID = "kContentCellID"

    private let layout = FlowLayout()
    
    private lazy var collectionView: UICollectionView = {
        
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.dataSource = self
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }()
    
    private lazy var datas: [String] = {
        var ds: [String] = []
        for i in 0..<20 {
            ds.append("\(i)")
        }
        return ds
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kContentCellID)
        collectionView.mj_header = MJRefreshHeader(refreshingBlock: { [weak self] in
            self?.layout.invalidateLayout()
            self?.collectionView.mj_header?.endRefreshing()
            self?.collectionView.reloadData()
        })

    }

}

extension FlowLayoutViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kContentCellID, for: indexPath)
        
        cell.backgroundColor = UIColor.randomColor()
        if let label = cell.viewWithTag(101) as? UILabel {
            label.text = datas[indexPath.item]
            label.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        } else {
            let label = UILabel()
            label.text = datas[indexPath.item]
            label.textColor = UIColor.black
            label.tag = 101
            cell.contentView.addSubview(label)
            label.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        }
        return cell
    }
}

extension FlowLayoutViewController: FlowLayoutDataSource {
    public func flowLayoutHeight(_ layout: FlowLayout, indexPath: IndexPath) -> CGFloat {
        return CGFloat(arc4random_uniform(150) + 100)
    }
    
    private func numberOfColumnsInFlowLayout(_ layout: FlowLayout) -> Int{
        return 2
    }
}

extension FlowLayoutViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == datas.count - 1 {
            DispatchQueue.main.async {
                let count = self.datas.count
                for i in 0..<20 {
                    self.datas.append("\(count+i)")
                }
                self.collectionView.reloadData()
            }
            
        }
    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
    }
    
    class func randomColor() -> UIColor {
        return UIColor(r: CGFloat(arc4random_uniform(256)), g: CGFloat(arc4random_uniform(256)), b: CGFloat(arc4random_uniform(256)))
    }
}
