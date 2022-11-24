//
//  PagingProtocols.swift
//  See
//
//  Created by Khater on 11/11/22.
//

import UIKit

// MARK: - DataSource
// class keyword means:  Only class types (and not structures or enumerations) can adopt this protocol.
// no difference between class and AnyObject as i know right now
protocol PagingCollectionViewDataSource: AnyObject{
    func pagingCollectionView(_ subCollectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    func pagingCollectionView(_ subCollectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
}



// MARK: - Delegate
protocol PagingCollectionViewDelegate: AnyObject{
    func pagingCollectionView(_ subCollectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
}



// MARK: - Delegate Extension
extension PagingCollectionViewDelegate{
    func pagingCollectionView(_ subCollectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){}
}



// MARK: - FlowLayout
protocol PagingCollectionViewDelegateFlowLayout: PagingCollectionViewDelegate{
    func pagingCollectionView(_ subCollectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    func pagingCollectionView(_ subCollectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    func pagingCollectionView(_ subCollectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
}



// MARK: - FlowLayout Extension
extension PagingCollectionViewDelegateFlowLayout{
    func pagingCollectionView(_ subCollectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize()
    }
    
    func pagingCollectionView(_ subCollectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return CGFloat()
    }
    
    func pagingCollectionView(_ subCollectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return CGFloat()
    }
}



// MARK: - Scroll Delegate
protocol PagingCollectionViewScrollDelegate: AnyObject {
    func pagingCollectionViewsDidScrollSubCollectionView(_ scrollView: UIScrollView)
    func pagingCollectionViewDidSelectSubCollectionView(at index: Int)
}


protocol PagingCollectionViewLinkedWithSegmentControlDelegate: AnyObject {
    func pagingCollectionViewDidScroll(for x: CGFloat)
    func pagingCollectionViewDidSelectIndex(at index: Int)
}
