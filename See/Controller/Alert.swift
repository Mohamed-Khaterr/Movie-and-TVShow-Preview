//
//  Alert.swift
//  See
//
//  Created by Khater on 10/22/22.
//

import Foundation
import UIKit


struct Alert{
    static func show(to vc: UIViewController, title: String? = nil, message: String, compeltionHandler: (() -> Void)?){
        DispatchQueue.main.async {
            let blurEffect = UIBlurEffect(style: .prominent)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = vc.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
            vc.view.addSubview(blurEffectView)
            
            
            let alert = UIAlertController(title: title ?? "Failure", message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                blurEffectView.removeFromSuperview()
                compeltionHandler?()
            }))
            
            
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    static func successMessage(to vc: UIViewController, message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            vc.present(alert, animated: true, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
}
