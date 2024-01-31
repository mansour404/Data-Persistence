//
//  UIButton + Extensions.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 12/01/2024.
//

import UIKit

extension UIButton {
    
    // MARK: - Corner radius
    func addCornerRadius(_ cornerRadius: CGFloat = 10, borderWidth: CGFloat = 2.0, borderColor: CGColor? = UIColor.white.cgColor) {
        clipsToBounds = true
        //layer.sh
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor
        layer.borderWidth = borderWidth
    }
}
