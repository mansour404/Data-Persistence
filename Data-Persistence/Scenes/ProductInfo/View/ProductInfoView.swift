//
//  ProductInfoView.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 18/01/2024.
//

import UIKit
import Lottie

protocol ProductInfoDelegate: AnyObject {
    func addToFav(id: Int?)
    func removeFromFav(id: Int?)
}

protocol ProductInfoProtocol: AnyObject {
    func updateProductImage(_ imageUrl: String?)
}

class ProductInfoView: UIViewController {
    
    // MARK: - Vars
    var product: Product?
    weak var delegate: ProductInfoDelegate?
    private var animationView: LottieAnimationView?
    
    private var presenter: ProductInfoPresenter!
    private let flowLayout = ZoomAndSnapFlowLayout()
    private var imageState: FavouriteState = .notFavourite


    // MARK: - Outlet
    @IBOutlet weak var vendorLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!

    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPresenter()
        setupCollectionView()
        setupView()
        setupButton()
        roundTopViewFromBottom()
        setupFavouriteButton()
        setupNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Action
    @IBAction func addToCartButtonPressed(_ sender: Any) {
        print("addToCartButtonPressed")
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - DataSource
extension ProductInfoView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.getItemsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductImageCell.identifier, for: indexPath) as? ProductImageCell else { return UICollectionViewCell() }
        presenter.configureCell(cell: cell, for: indexPath.item)
        return cell
    }
    
}

// MARK: - Delegate
extension ProductInfoView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt", indexPath.item)
        presenter.updateProductImage(for: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("from willDisplay cell: ",indexPath.item)
        //presenter.updateProductImage(for: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        print("willDisplaySupplementaryView: ", indexPath.item)
    }
    
    //    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    //    }
    
}

// MARK: - Setup view
extension ProductInfoView {
    
    private func setupPresenter() {
        presenter = ProductInfoPresenter(view: self, product: product)
        presenter.viewDidLoad()
    }
    
    private func setupCollectionView() {
        let nib = UINib(nibName: String(describing: ProductImageCell.self), bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: ProductImageCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = flowLayout
        collectionView.contentInsetAdjustmentBehavior = .always
    }
    
    private func setupView() {
        vendorLabel.text = product?.vendor
        priceLabel.text = product?.variants?.first?.price
        titleLabel.text = product?.title
        descriptionLabel.text = product?.bodyHtml
        productImageView.downloadImage(from: product?.images?.first?.src)
    }
    
    private func roundTopViewFromBottom() {
        let cornerRadius = self.view.frame.size.width // 2
        topView.round(corners: [.bottomLeft, .bottomRight], cornerRadius: cornerRadius)
    }
    
    private func setupButton() {
        addToCartButton.addCornerRadius(8, borderWidth: 2.0, borderColor: UIColor.black.cgColor)
    }
    
}

// MARK: - ProductInfoProtocol
extension ProductInfoView: ProductInfoProtocol {
    func updateProductImage(_ imageUrl: String?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.productImageView.downloadImage(from: imageUrl)
        }
    }
}

// MARK: - Favourite Button
extension ProductInfoView {
    private func setupFavouriteButton() {
        favouriteButton.setImage(UIImage(systemName: ImageName.notFavourite), for: .normal)
        favouriteButton.setImage(UIImage(systemName: ImageName.favourite), for: .selected)
        favouriteButton.addTarget(self, action: #selector(toggleFavourite), for: .touchUpInside)
        favouriteButton.backgroundColor = .clear
        
        if presenter.isProductFavourite() {
            favouriteButton.isSelected = true
            favouriteButton.tintColor = .red
        }
        else {
            favouriteButton.isSelected = false
            favouriteButton.tintColor = .white
        }
    }
    
    func playAnimation(name: String) {
        animationView = .init(name: name)
        animationView!.frame = view.bounds
        animationView!.contentMode = .scaleAspectFit
        // 4. Set animation loop mode
        animationView!.loopMode = .playOnce
        view.addSubview(animationView!)
        // 6. Play animation
        animationView?.play { [weak self] _ in
            self?.animationView?.removeFromSuperview()
        }
    }
    
    @objc func toggleFavourite(sender: UIButton) {
        // Toggle the selected state to change the button's image
        sender.isSelected.toggle()
        if sender.isSelected {
            // Add to fav
            sender.tintColor = .red
            addToFavourites()
            playAnimation(name: LottieJson.favorite)
        } else {
            // Remove from Fav
            sender.tintColor = .white
            removeFromFavourites()
            playAnimation(name: LottieJson.removeFavourite)
        }
    }
    
    func addToFavourites() {
        delegate?.addToFav(id: product?.id)
    }
    
    func removeFromFavourites() {
        delegate?.removeFromFav(id: product?.id)
    }
}

// MARK: - Notification Center
extension ProductInfoView {
    private func setupNotification() {
        // Add observer for listening to notifcation
        NotificationCenter.default.addObserver(self, selector: #selector(listenToNotification), name: NSNotification.Name(NotificationName.notifyUpdate), object: nil)
    }
    
    @objc func listenToNotification(notification: Notification) {
        let wishlistViewModel = notification.object as? WishlistViewModel
        let backedProductId = wishlistViewModel?.backProductId
        if product?.id == backedProductId {
            favouriteButton.isSelected = !favouriteButton.isSelected
        }
    }
}
