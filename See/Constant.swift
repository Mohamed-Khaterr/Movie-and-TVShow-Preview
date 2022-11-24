//
//  Constant.swift
//  See
//
//  Created by Khater on 10/22/22.
//

import Foundation
import UIKit


struct Constant{
    static let defaultImageName = "Icon"
    static let userCircleImageName = "UserCircle"
    static let favourite = "favourite"
    static let favouriteFill = "favourite-fill"
    static let bookmark = "bookmark"
    static let bookmarkFill = "bookmark-fill"
    static let star = "star"
    static let starFill = "star.fill"
    
    
    static let blackColorName = "Black Color"
    static let whiteColor = "White Color"
    static let constantDarkGray = "Constant Dark Gray Color"
    static let lightDark = "Light Dark Color"
    static let lightGray = "Light Gray Color"
    
    static let catalogCollectionViewFooterIdentifier = "CollectionViewFooter"
    
    static func defaultUIImage() -> UIImage?{
        return UIImage(named: Constant.defaultImageName)
    }
    
    static let currentYear: Int = Calendar.current.component(.year, from: .now)
}
