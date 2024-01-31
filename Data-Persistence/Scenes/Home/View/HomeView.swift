//
//  HomeView.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 12/01/2024.
//

import UIKit
import Lottie

class HomeView: UIViewController {

    // MARK: - Vars
    lazy var viewModel: HomeViewModel = {
        return HomeViewModel()
    }()
    private var animationView: LottieAnimationView?

    // MARK: Refresh Controller
    lazy var refresher: UIRefreshControl = {
        let refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: RefresherTitle.stayUpdated)
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresher
    }()

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sortingAlphabeticalButton: UIButton!
    @IBOutlet weak var sortingpricingButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var productsCountLabel: UILabel!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        // Init the static view
        initView()
        // Init view model, bindViewModel
        initVM()
        // Notification
        //setupNotification()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Action
    @objc private func handleRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Presenting alert at the same time refreshController is trying to stop itself.
            // So in my case I put endRefreshing code after 1 second.
            self.refresher.endRefreshing()
        }
        viewModel.initFetch()
    }
}

// MARK: - Data source
extension HomeView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCollectionViewCell.identifier, for: indexPath) as? ProductCollectionViewCell else { return UICollectionViewCell() }
        let cellVM = viewModel.getCellViewModel(at: indexPath)
        cell.homeCellViewModel = cellVM
        cell.delegate = self
        return cell
    }
}

// MARK: - Delegate
extension HomeView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ProductInfoView(nibName: NibName.productInfoView, bundle: nil)
        vc.product = viewModel.getFilteredProduct(at: indexPath)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Delegate FlowLayout
extension HomeView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width * 0.485
        return CGSize.init(width: width, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.7
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 4, bottom: 1, right: 4)
    }
    
}

// MARK: - Configure view
extension HomeView {
    private func initView() {
        let selectedColor = UIColor(hex: "#F4F4F4FF")
        self.collectionView.backgroundColor = selectedColor
        //self.navigationItem.title = "Products"
        let nib = UINib(nibName: String(describing: ProductCollectionViewCell.self), bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: ProductCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self // Search Delegate
        collectionView.addSubview(refresher) // Add refresher
    }

    
    private func showAlert(_ message: String, actions: [UIAlertAction] = [UIAlertAction(title: AlertMessage.ok, style: .default)]) {
        let cancelAction = UIAlertAction(title: AlertMessage.cancel, style: .cancel)
        let confirmAction = UIAlertAction(title: AlertMessage.ok, style: .destructive) { _ in
            self.viewModel.runConfirmAction()
        }
        Alert.showAlert(target: self, title: AlertMessage.alert, message: message, actions: [cancelAction, confirmAction])
    }
    
}

// MARK: - Binding
extension HomeView {
    private func initVM() {
        // Naive binding
        viewModel.showAlertClosure = { [weak self] () in
            guard let self else { return }
            DispatchQueue.main.async {
                if let message = self.viewModel.alertMessage, message != AlertMessage.deleteConfrimMessage {
                    let okAction = UIAlertAction(title: "Ok", style: .default)
                    self.showAlert(message, actions: [okAction])
                } else {
                    self.showAlert(AlertMessage.deleteConfrimMessage)
                }
            }
        }

        viewModel.updateLoadingStatus = { [weak self] () in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch self.viewModel.state {
                case .empty, .error:
                    self.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self.collectionView.alpha = 0.0 // hide collection view
                    })
                case .loading:
                    self.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self.collectionView.alpha = 0.0 // hide collection view
                    })
                case .populated:
                    self.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self.collectionView.alpha = 1.0 // show collection view
                    })
                }
            }
        }
        
        viewModel.reloadCollectionViewClosure = { [weak self] () in
            guard let self else { return }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        viewModel.updateLabelClosure = { [weak self] text in
            guard let self else { return }
            DispatchQueue.main.async {
                self.productsCountLabel.text = text
            }
        }
        
        // MARK: Finally
        viewModel.initFetch()
    }
    
}

// MARK: - Search Delegate
extension HomeView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchProduct(searchText: searchText)
    }
    
    // TODO: - Handel cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewModel.isSearching = false
        collectionView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        viewModel.searchProduct(searchText: searchBar.text ?? "")
    }
    
    // TODO: - Handel touches began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.becomeFirstResponder()
        viewModel.isSearching = false
        collectionView.reloadData()
    }

}

extension HomeView: ProductCollectionViewCellDelegate {
    func addToFavourites(id: Int?) {
        viewModel.addToFavourites(id: id)
    }
    
    func removeFromFavourites(id: Int?) {
        viewModel.removeFromFavourites(id: id)
    }
}

extension HomeView: ProductInfoDelegate {
    func addToFav(id: Int?) {
        viewModel.addToFavourites(id: id)
    }
    
    func removeFromFav(id: Int?) {
        //viewModel.removeFromFavourites(id: id)
        viewModel.removeFromFavForOtherVCs(id: id)
    }
}
