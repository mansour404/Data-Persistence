//
//  UIImageView + Extensions.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 12/01/2024.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    // MARK: - Download image from string url
    func downloadImage(from stringURL: String?, placeHolder: String = "BlankPng", completion: ((Result<UIImage?, Error>) -> Void)? = nil) {
        guard let stringURL = stringURL, let url = URL(string: stringURL) else {
            image = UIImage(named: placeHolder)
            return
        }
        kf.indicatorType = .activity
        kf.setImage(with: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let imageRes):
                self.image = imageRes.image
                completion?(.success(imageRes.image))
            case .failure(let error):
                print(error.localizedDescription)
                self.image = UIImage(named: placeHolder)
                completion?(.failure(error))
            }
        }
    }
    
    
    // MARK: - Make imageView rounded
    func rounded(_ value: Float?) {
       clipsToBounds = true
        // Set the corner radius to make the imageView circular
        if let value = value {
            layer.cornerRadius = CGFloat(value)
        } else {
            layer.cornerRadius = min(frame.size.width, frame.size.height) / 2.0
        }
        layer.masksToBounds = true
    }
    
    func addBorder(width: CGFloat = 0.5, color: CGColor = UIColor.systemGray.cgColor) {
        // Add a circular black stroke (border) around the image view
        layer.borderWidth = width // Adjust the border width as needed
        layer.borderColor = color
    }
}
