//
//  SortingTableViewCell.swift
//  See
//
//  Created by Khater on 10/29/22.
//
/*
    border and cornerRadius is added in xib file
*/
import UIKit

class SortingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var newestView: UIView!
    @IBOutlet weak var popularView: UIView!
    @IBOutlet weak var ratingView: UIView!
    
    var delegate: FilterDelegate?
    
    public var sorted: TMDB.Sort = .releaseDateDesc {
        didSet{
            deselectAllViews()
            if sorted == .releaseDateDesc{
                selectView(newestView)
            }else if sorted == .popularityDesc{
                selectView(popularView)
            }else if sorted == .voteAverageDesc{
                selectView(ratingView)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        addBorderForAllViews()
    }
    
    private func addBorderForAllViews(){
        [newestView, popularView, ratingView].forEach { view in
            view?.addBorder(UIColor(named: Constant.blackColorName))
        }
    }
    
    @IBAction func sortingButtonPressed(_ button: UIButton) {
        switch button.currentTitle{
        case "Newest":
            sorted = .releaseDateDesc
            
        case "Popular":
            sorted = .popularityDesc
            
        case "Rating":
            sorted = .voteAverageDesc
            
        default:
            return
        }
        
        delegate?.didSelectSort(sortBy: sorted)
    }
    
    private func selectView(_ view: UIView){
        let centerView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        centerView.center = view.center
        centerView.cornerRadius()
        centerView.backgroundColor = UIColor(named: Constant.blackColorName)
        
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(named: Constant.blackColorName)?.cgColor
        view.backgroundColor = UIColor(named: Constant.whiteColor)
        
        centerView.tag = 10110
        
        view.addSubview(centerView)
    }
    
    private func deselectAllViews(){
        [newestView, popularView, ratingView].forEach { view in
            if let viewWithTag = view?.viewWithTag(10110){
                viewWithTag.removeFromSuperview()
            }
        }
    }
}


// MARK: - Static Constants
extension SortingTableViewCell{
    static let identifiter = "SortingTableViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "SortingTableViewCell", bundle: nil)
    }
}
