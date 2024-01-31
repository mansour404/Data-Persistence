//
//  TempView.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 30/01/2024.
//

import Foundation

// MARK: - Using image not button for product fav or not
//extension ProductInfoView {
//    private func setFavouriteImageView() {
//        if presenter.isProductFavourite() {
//            favouriteImageView.image = UIImage(systemName: "suit.heart.fill")
//            favouriteImageView.tintColor = .red
//            imageState = .favourite
//        } else {
//            favouriteImageView.image = UIImage(systemName: "suit.heart");
//            favouriteImageView.tintColor = .white
//            imageState = .notFavourite
//        }
//    }
//
//
//    private func setupGestureRecognizer() {
//        let favrouiteGesture = UITapGestureRecognizer(target: self, action: #selector(getFiredFav(_:)))
//        favouriteImageView.addGestureRecognizer(favrouiteGesture)
//        favouriteImageView.isUserInteractionEnabled = true
//    }
//
//    @objc func getFiredFav(_ sender: UITapGestureRecognizer) {
//        switch imageState {
//        case .favourite:
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                self.favouriteImageView.image = UIImage(named: "suit.heart")
//                self.favouriteImageView.tintColor = .white
//            }
//            imageState = .notFavourite
//            delegate?.removeFromFav(id: product?.id)
//        case .notFavourite:
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                self.favouriteImageView.image = UIImage(named: "suit.heart.fill")
//                self.favouriteImageView.tintColor = .red
//            }
//            imageState = .favourite
//            delegate?.addToFav(id: product?.id)
//        }
//    }
//}

//        setFavouriteImageView()
//        setupGestureRecognizer()
//    @IBOutlet weak var favouriteImageView: UIImageView!
