//
//  PagingCollectionView.swift
//  See
//
//  Created by Khater on 11/7/22.
//

import UIKit


final class PagingCollectionView: UICollectionView{
    
    weak var pagingDataSource: PagingCollectionViewDataSource?
    private weak var pagingDelegateFlowLayout: PagingCollectionViewDelegateFlowLayout?
    weak var pagingDelegate: PagingCollectionViewDelegate?{
        didSet{
            pagingDelegateFlowLayout = pagingDelegate as? PagingCollectionViewDelegateFlowLayout
        }
    }
    
    weak var scrollDelegate: PagingCollectionViewScrollDelegate?
    
    // ScrollWithSegmentDelegate and SegmentControl they link PagingCollectionView class and CustomeSegmentControl class with each other
    private weak var scrollWithSegmentDelegate: PagingCollectionViewLinkedWithSegmentControlDelegate?
    weak var segmentControl: CustomSegmentControl? {
        didSet{
            if let segmentControl = segmentControl {
                // Set delegate of Custom Segment Control
                segmentControl.delegate = self
                // Set delegate of Collection View Scrolling
                scrollWithSegmentDelegate = segmentControl
            }
        }
    }
    
    
    private var subCollectionViews: [UICollectionView] = []
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: "PagingCollectionViewCell")
        delegate = self
        dataSource = self
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
        
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout{
            flowLayout.scrollDirection = .horizontal
        }
    }
    
    public func addSubCollectionViews(_ collectionViews: [UICollectionView]){
        subCollectionViews = collectionViews
        
        subCollectionViews.forEach { collectionView in
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
}



// MARK: - DataSource
extension PagingCollectionView: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self {
            return subCollectionViews.count
        } else {
            if pagingDataSource != nil {
                return pagingDataSource!.pagingCollectionView(collectionView, numberOfItemsInSection: section)
            } else {
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PagingCollectionViewCell", for: indexPath)
            let subCollectionView = subCollectionViews[indexPath.row]
            subCollectionView.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
            cell.addSubview(subCollectionView)
            return cell
            
        }else{
            if pagingDataSource != nil {
                return pagingDataSource!.pagingCollectionView(collectionView, cellForItemAt: indexPath)
            } else {
                return UICollectionViewCell()
            }
        }
    }
}



// MARK: - Delegate
extension PagingCollectionView: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView != self && pagingDelegate != nil {
            pagingDelegate!.pagingCollectionView(collectionView, didSelectItemAt: indexPath)
        }
    }
}



// MARK: - FlowLayout
extension PagingCollectionView: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self {
            return CGSize(width: frame.width, height: frame.height)
            
        }else{
            return pagingDelegateFlowLayout?.pagingCollectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? CGSize()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self{
            return 0
        }else{
            return pagingDelegateFlowLayout?.pagingCollectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section) ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self{
            return 0
        }else{
            return  pagingDelegateFlowLayout?.pagingCollectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section) ?? 0
        }
    }
}



// MARK: - Scroll Delegate
extension PagingCollectionView: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0 {
            // Sub Collection Views scrolling Verticaly
            scrollDelegate?.pagingCollectionViewsDidScrollSubCollectionView(scrollView)
        }
        
        if scrollView.contentOffset.x != 0{
            // Paging Collection View scrolling Horizontaly
            scrollWithSegmentDelegate?.pagingCollectionViewDidScroll(for: scrollView.contentOffset.x)
        }
        
        if scrollView.contentOffset.y == 0 {
            // Prevent selectedIndex form reset to zero
            let selectedIndex = scrollView.contentOffset.x / frame.width
            let roundSelectedIndex = round(selectedIndex)
            
            scrollWithSegmentDelegate?.pagingCollectionViewDidSelectIndex(at: Int(roundSelectedIndex))
            scrollDelegate?.pagingCollectionViewDidSelectSubCollectionView(at: Int(roundSelectedIndex))
        }
        
    }
}



// MARK: - Segment Control Delegate
extension PagingCollectionView: CustomSegmentControlDelegate{
    func didIndexChange(at index: Int) {
        scrollRectToVisible(CGRect(x: frame.width * CGFloat(index), y: frame.origin.y, width: frame.width, height: frame.height), animated: true)
    }
}
