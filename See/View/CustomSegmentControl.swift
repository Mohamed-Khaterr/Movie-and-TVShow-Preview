//
//  CustomSegmentControl.swift
//  See
//
//  Created by Khater on 11/11/22.
//

import Foundation
import UIKit


protocol CustomSegmentControlDelegate: AnyObject{
    func didIndexChange(at index: Int)
}

@IBDesignable class CustomSegmentControl: UIView{
    
    private var lineView = UIView()
    private var stackView = UIStackView()
    
    weak var delegate: CustomSegmentControlDelegate?
    
    private var buttons: [UIButton] = []
    
    @IBInspectable var textColor: UIColor = .blue{
        didSet{
            for button in buttons {
                button.tintColor = textColor
            }
        }
    }
    
    @IBInspectable var lineColor: UIColor = .black {
        didSet{
            lineView.backgroundColor = lineColor
        }
    }
    
    @IBInspectable var commaSeparatedButtonTitles: String = ""{
        didSet{
            buttons.removeAll()
            
            let buttonTitles = commaSeparatedButtonTitles.components(separatedBy: ",")
            
            for buttonTitle in buttonTitles {
                let button = UIButton(type: .system)
                button.setTitle(buttonTitle, for: .normal)
                button.titleLabel!.font = UIFont(name: "Inter-Regular", size: 17)
                button.titleLabel?.numberOfLines = 0
                button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
                
                buttons.append(button)
            }
            
            updateView()
        }
    }
    
    private func updateView(){
        subviews.forEach { view in
            view.removeFromSuperview()
        }
        
        createStackView()
        createLineView()
    }
    
    
    private func createStackView(){
        stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    private func createLineView(){
        lineView.backgroundColor = .black
        
        addSubview(lineView)

        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        lineView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        lineView.widthAnchor.constraint(equalToConstant: (frame.width / CGFloat(buttons.count))).isActive = true

        
        lineView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        
        lineView.topAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
        lineView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    
    override var intrinsicContentSize: CGSize {
        // Fixed Height
        return CGSize(width: UIView.noIntrinsicMetric, height: 40)
    }
    
    @objc private func buttonPressed(_ button: UIButton){
        let selectedIndex = buttons.firstIndex(of: button)!
        if delegate != nil {
            delegate!.didIndexChange(at: selectedIndex)
        } else {
            lineView.transform.tx = button.frame.origin.x
        }
    }
}


// MARK: - PagingCollectionView Delegate
extension CustomSegmentControl: PagingCollectionViewLinkedWithSegmentControlDelegate{
    func pagingCollectionViewDidScroll(for x: CGFloat) {
        let index = Int(round(x / frame.width))
        var buttonPositionX: CGFloat = 0
        if index < buttons.count{
            buttonPositionX = buttons[index].frame.origin.x
        }
        
        let positionX = (x / CGFloat(buttons.count))
        
        if index == (buttons.count - 1) {
            if positionX < buttonPositionX {
                lineView.transform.tx = positionX
            }
        }else{
            lineView.transform.tx = positionX
        }
    }
    
    func pagingCollectionViewDidSelectIndex(at index: Int) {
        if index < buttons.count{
            //lineView.transform.tx = buttons[index].frame.origin.x
        }
    }
}
