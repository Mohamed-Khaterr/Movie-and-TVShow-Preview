//
//  FilterCollectionViewCell.swift
//  See
//
//  Created by Khater on 10/30/22.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    static let identifiter = "FilterCollectionViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "FilterCollectionViewCell", bundle: nil)
    }
    
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cornerRadius(20)
    }

}
