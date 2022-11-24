//
//  GenreTableViewCell.swift
//  See
//
//  Created by Khater on 10/30/22.
//

import UIKit

class GenreTableViewCell: UITableViewCell {
    
    @IBOutlet weak var selectedGenreLabel: UILabel!
    
    var selectedGenre: String = ""{
        didSet{
            selectedGenreLabel.text = selectedGenre
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }
}


// MARK: - Static Constants
extension GenreTableViewCell{
    static let identifiter = "GenreTableViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "GenreTableViewCell", bundle: nil)
    }
}
