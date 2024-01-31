//
//  ProductCollectionViewCell.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 18/01/2024.
//

import UIKit

protocol ProductCollectionViewCellDelegate: AnyObject {
    func addToFavourites(id: Int?)
    func removeFromFavourites(id: Int?)
}

class ProductCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Vars
    weak var delegate: ProductCollectionViewCellDelegate?
    var imageState: FavouriteState = .notFavourite
    var productId: Int?
    
    // MARK: - Outlets
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var vnedorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var favouriteImageView: UIImageView!
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        setupGestureRecognizer()
    }
    
    var homeCellViewModel: ProductModelDB? {
        didSet {
            vnedorLabel.text = homeCellViewModel?.vendor
            titleLabel.text = homeCellViewModel?.title
            priceLabel.text = homeCellViewModel?.price
            productImage.downloadImage(from: homeCellViewModel?.imageText)
            productId = homeCellViewModel?.id
            setFavouriteImageView()
        }
    }
    
    func setFavouriteImageView() {
        guard let fav = homeCellViewModel?.isFavourite else { return }
        if fav {
            favouriteImageView.image = UIImage(systemName: ImageName.favourite)
            favouriteImageView.tintColor = .red
            imageState = .favourite
        }
        else {
            favouriteImageView.image = UIImage(systemName: ImageName.notFavourite);
            favouriteImageView.tintColor = .label
            imageState = .notFavourite
        }
    }
    
    private func setupView() {
        productView.layer.cornerRadius = 10 // round productView
        productView.clipsToBounds = true
    }
    
    func setupGestureRecognizer() {
        let favrouiteGesture = UITapGestureRecognizer(target: self, action: #selector(getFiredFav(_:)))
        favouriteImageView.addGestureRecognizer(favrouiteGesture)
        favouriteImageView.isUserInteractionEnabled = true
    }
    
    @objc func getFiredFav(_ sender: UITapGestureRecognizer) {
        switch imageState {
        case .favourite:
//            favouriteImageView.image = UIImage(named: "suit.heart")
//            imageState = .notFavourite
            delegate?.removeFromFavourites(id: productId)
        case .notFavourite:
//            favouriteImageView.image = UIImage(named: "suit.heart.fill")
//            imageState = .favourite
            delegate?.addToFavourites(id: productId)
        }
    }
    
}
