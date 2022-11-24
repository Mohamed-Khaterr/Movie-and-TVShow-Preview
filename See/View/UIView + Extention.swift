//
//  UIView + Extention.swift
//  See
//
//  Created by Khater on 10/19/22.
//

import Foundation
import UIKit

extension UIView{
    // MARK: - Borders
    func addBorder(_ color: UIColor? = nil){
        self.layer.borderWidth = 1
        if let color = color{
            self.layer.borderColor = color.cgColor
        }else{
            self.layer.borderColor = UIColor(named: "Gray Color")?.cgColor
        }
    }
    
    
    // MARK: - Corner Radius
    func cornerRadius(_ ratio: CGFloat? = nil){
        if let ratio = ratio {
            self.layer.cornerRadius = ratio
        }else{
            self.layer.cornerRadius = self.frame.height / 2
        }
    }
    
    
    // MARK: - Gradient
    func makeGradientLayer(cornerRadius ratio: CGFloat? = nil){
        layer.sublayers?.forEach({ layer in
            if ((layer as? CAGradientLayer) != nil){
                layer.removeFromSuperlayer()
            }
        })
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [UIColor.clear, UIColor.black.cgColor]
        
        if let ratio = ratio {
            gradientLayer.cornerRadius = ratio
        }
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        //gradientLayer.locations = [0.0, 0.7]
        
        clipsToBounds = true
        layer.addSublayer(gradientLayer)
    }
}
