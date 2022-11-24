//
//  SavedCollectionViewCell.swift
//  See
//
//  Created by Khater on 11/3/22.
//

import UIKit

class SavedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    public var representedIdentifier: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        
        button.cornerRadius()
        imageView.cornerRadius(15)
    }
}


extension SavedCollectionViewCell{
    static let identifier = "SavedCollectionViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "SavedCollectionViewCell", bundle: nil)
    }
}
