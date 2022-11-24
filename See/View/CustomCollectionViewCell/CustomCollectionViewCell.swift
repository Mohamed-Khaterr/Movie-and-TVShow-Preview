//
//  CustomCollectionViewCell.swift
//  See
//
//  Created by Khater on 10/20/22.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
        
    public var representedIdentifier: String = ""
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setupCellUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellUI()
    }
    
    private func setupCellUI(){
        titleLabel.text = ""
        genreLabel.text = ""
        
        imageView.cornerRadius(20)
        
        loadingIndicator.startAnimating()
        imageView.image = Constant.defaultUIImage()
    }
    
    public func displayData(_ show: Show){
        titleLabel.text = show.title ?? show.name!
        genreLabel.text = show.genreString
    }
    
    public func setImageView(with data: Data?){
        loadingIndicator.stopAnimating()
        if let data = data {
            imageView.image = UIImage(data: data)
            layoutIfNeeded()
        }
    }
}


// MARK: - Cell Statics
extension CustomCollectionViewCell{
    static let identifier = "CustomCollectionViewCell"

    static func nib() -> UINib{
        return UINib(nibName: "CustomCollectionViewCell", bundle: nil)
    }
}
