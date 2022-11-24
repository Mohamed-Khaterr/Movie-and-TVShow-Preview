//
//  CastCollectionViewCell.swift
//  See
//
//  Created by Khater on 10/27/22.
//

import UIKit

class CastCollectionViewCell: UICollectionViewCell {
    

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    public var representedIdentifier = ""
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setupCellUI()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellUI()
    }
    
    private func setupCellUI(){
        loadingIndicator.startAnimating()
        
        setupImageView()
        imageView.cornerRadius()
        imageView.image = Constant.defaultUIImage()
        
        nameLabel.text = "Name"
        departmentLabel.text = "Department"
    }
    
    private func setupImageView(){
        imageView.layer.masksToBounds = true
        layoutIfNeeded()
    }
    
    public func displayData(cast: Cast){
        nameLabel.text = cast.name
        departmentLabel.text = cast.department
    }
    
    public func setProfileImage(with data: Data?){
        loadingIndicator.stopAnimating()
        setupImageView()
        if let data = data {
            imageView.image = UIImage(data: data)
        }else{
            imageView.image = UIImage(named: Constant.userCircleImageName)
        }
    }
}


// MARK: - Cell Statics
extension CastCollectionViewCell{
    static let identifier = "CastCollectionViewCell"

    static func nib() -> UINib{
        return UINib(nibName: "CastCollectionViewCell", bundle: nil)
    }
}
