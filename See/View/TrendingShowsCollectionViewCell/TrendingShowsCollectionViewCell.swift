//
//  HeaderMovieCollectionViewCell.swift
//  See
//
//  Created by Khater on 10/19/22.
//

import UIKit

class TrendingShowsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var typeOfShowLView: UIView!
    @IBOutlet weak var typeOfShowLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearAndGenreLabel: UILabel!
    @IBOutlet weak var popularityView: UIView!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var voteRateView: UIView!
    @IBOutlet weak var voteRateLabel: UILabel!
    
    @IBOutlet weak var gradientView: UIView!
    
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
        setBoredersForViews()
        makeLabelsTextEmpty()
        addCornerRadiusToViews()
        
        // Create Gradient Layer for Cell
        gradientView.makeGradientLayer(cornerRadius: 20)
        
        imageView.image = Constant.defaultUIImage()
        loadingIndicator.startAnimating()
    }
    
    private func setBoredersForViews(){
        // Make Gray Border to Specific Views
        [typeOfShowLView, popularityView, voteRateView].forEach { view in
            view?.addBorder()
        }
    }
    
    private func makeLabelsTextEmpty(){
        [titleLabel, typeOfShowLabel, yearAndGenreLabel, popularityLabel, voteRateLabel].forEach { label in
            label.text = ""
        }
    }
    
    private func addCornerRadiusToViews(){
        // Make Rounded Corners to specific UI Elements
        typeOfShowLView.cornerRadius(13)
        imageView.cornerRadius(20)
        popularityView.cornerRadius(10)
        voteRateView.cornerRadius(10)
        gradientView.cornerRadius(20)
    }
    
    public func displayData(_ trend: Show){
        titleLabel.text = trend.title ?? trend.name! // Name for TV Show and title for Movie
        typeOfShowLabel.text = trend.mediaType!.rawValue
        yearAndGenreLabel.text = trend.releaseYear + ", " + trend.genreString
        popularityLabel.text = "Popularity " + trend.popularityString
        voteRateLabel.text = "Vote " + trend.voteAverageString
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
extension TrendingShowsCollectionViewCell{
    static let identifier = "TrendingShowsCollectionViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "TrendingShowsCollectionViewCell", bundle: nil)
    }
}
