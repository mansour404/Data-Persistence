//
//  ProductImageCell.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 24/01/2024.
//

import UIKit

protocol ProductCellProtocol {
    func displayImage(by stringUrl: String?)
}

class ProductImageCell: UICollectionViewCell {
    
    // MARK: - Vars
    weak var view: ProductInfoDelegate?
    private var cellImage: UIImage?
    
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        productImageView.layer.cornerRadius = 8
        productImageView.clipsToBounds = true
        productImageView.addBorder(width: 0.5, color: UIColor.lightGray.cgColor)
    }
}

// MARK: - Product cell protocol
extension ProductImageCell: ProductCellProtocol {
    func displayImage(by stringUrl: String?) {
        productImageView.downloadImage(from: stringUrl) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                self.cellImage = image
            case .failure(let error):
                print(error)
            }
        }
    }
}
