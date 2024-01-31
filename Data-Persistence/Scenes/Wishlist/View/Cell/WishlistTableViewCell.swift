//
//  WishlistTableViewCell.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 28/01/2024.
//

import UIKit

class WishlistTableViewCell: UITableViewCell {

    // MARK: - Outlet
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none // disable selection style
        // remove separator, shift separatorInset to rigt by 500
        separatorInset = UIEdgeInsets(top: 0, left: 500, bottom: 0, right: 0)
        productImage.rounded(10)
        productImage.addBorder()
        cardView.dropShadow()
    }
    
    // MARK: Configure
    var productCellViewModel: ProductModelDB? {
        didSet {
            titleLabel.text = productCellViewModel?.title
            priceLabel.text = productCellViewModel?.price
            productImage.downloadImage(from: productCellViewModel?.imageText)
        }
    }
}
