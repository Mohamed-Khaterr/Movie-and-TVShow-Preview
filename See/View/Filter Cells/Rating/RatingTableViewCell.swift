//
//  RatingTableViewCell.swift
//  See
//
//  Created by Khater on 10/30/22.
//

import UIKit

class RatingTableViewCell: UITableViewCell {
    
    static let identifiter = "RatingTableViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "RatingTableViewCell", bundle: nil)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: FilterDelegate?
    
    var rates: [(rate: Double, isSelected: Bool)] = []{
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
extension RatingTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionViewCell.identifiter, for: indexPath) as! FilterCollectionViewCell
        
        
        if rates[indexPath.row].isSelected{
            cell.textLabel.textColor = UIColor(named: Constant.whiteColor)
            cell.backgroundColor = UIColor(named: Constant.blackColorName)
            
        }else{
            cell.textLabel.textColor = UIColor(named: Constant.blackColorName)
            cell.backgroundColor = UIColor(named: Constant.lightDark)
        }
        
        cell.textLabel.text = "\(rates[indexPath.row].rate)+"
        
        return cell
    }
}


// MARK: - CollectionView Delegate
extension RatingTableViewCell: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // User Select Rateing
        delegate?.didSelectRating(rate: Double(rates[indexPath.row].rate))
    }
}


// MARK: - CollectionView FlowLayout
extension RatingTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 40)
    }
}
