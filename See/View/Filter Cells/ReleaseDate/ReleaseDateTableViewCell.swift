//
//  ReleaseDateTableViewCell.swift
//  See
//
//  Created by Khater on 10/30/22.
//

import UIKit

class ReleaseDateTableViewCell: UITableViewCell {
    
    static let identifiter = "ReleaseDateTableViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "ReleaseDateTableViewCell", bundle: nil)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: FilterDelegate?

    var releaseDates: [(year: Int, isSelected: Bool)] = []{
        didSet{
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        collectionView.register(FilterCollectionViewCell.nib(), forCellWithReuseIdentifier: FilterCollectionViewCell.identifiter)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}


// MARK: - CollectionView DataSource
extension ReleaseDateTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return releaseDates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCell.identifiter, for: indexPath) as! FilterCollectionViewCell
        
        if releaseDates[indexPath.row].isSelected{
            cell.textLabel.textColor = UIColor(named: Constant.whiteColor)
            cell.backgroundColor = UIColor(named: Constant.blackColorName)
            
        }else{
            cell.textLabel.textColor = UIColor(named: Constant.blackColorName)
            cell.backgroundColor = UIColor(named: Constant.lightDark)
        }
        
        cell.textLabel.text = String(releaseDates[indexPath.row].year)
        
        return cell
    }
}


// MARK: - CollectionView Delegate
extension ReleaseDateTableViewCell: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Select Year
        delegate?.didSelectReleaseDate(year: releaseDates[indexPath.row].year)
    }
}


// MARK: - CollectionView FlowLayout
extension ReleaseDateTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 40)
    }
}
