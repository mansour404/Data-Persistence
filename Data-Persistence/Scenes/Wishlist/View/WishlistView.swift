//
//  WishlistView.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 28/01/2024.
//

import UIKit


class WishlistView: UIViewController {
    
    // MARK: - Variables
    lazy var viewModel: WishlistViewModel = {
        return WishlistViewModel() // initialized the default parameters
    }()
    
    // MARK: - Outlet
    @IBOutlet weak var wishlistTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var productsCountLabel: UILabel!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        // Init the static views
        configureTableView()
        // init view model, bindViewModel
        initVM()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        navigationController?.setNavigationBarHidden(true, animated: animated)
        configureTableView()
        initVM()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    

    //MARK: - Configure TableView
    private func configureTableView() {
        let selectedColor = UIColor(hex: "#F4F4F4FF")
        self.wishlistTableView.backgroundColor = selectedColor
        let nib = UINib(nibName: String(describing: WishlistTableViewCell.self), bundle: nil)
        wishlistTableView.register(nib, forCellReuseIdentifier: WishlistTableViewCell.identifier)
        wishlistTableView.dataSource = self
        wishlistTableView.delegate = self
    }
    
    private func showAlert(_ message: String, title: String = AlertMessage.alert) {
        let okAction = UIAlertAction(title: AlertMessage.ok, style: .default)
        Alert.showAlert(target: self, title: title, message: message, actions: [okAction])
    }
    
}

// MARK: - Binding
extension WishlistView {
    
    private func initVM() {
        // Naive binding
        viewModel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert(message)
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
                        self.wishlistTableView.alpha = 0.0 // hide collection view
                    })
                case .loading:
                    self.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self.wishlistTableView.alpha = 0.0 // hide collection view
                    })
                case .populated:
                    self.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self.wishlistTableView.alpha = 1.0 // show collection view
                    })
                }
            }
        }
        
        viewModel.reloadTableViewClosure = { [weak self] () in
            guard let self else { return }
            DispatchQueue.main.async {
                self.wishlistTableView.reloadData()
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

// MARK: - TableView DataSource
extension WishlistView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WishlistTableViewCell.identifier, for: indexPath) as? WishlistTableViewCell else {  return WishlistTableViewCell() }
        let cellVM = viewModel.getCellViewModel(at: indexPath)
        cell.productCellViewModel = cellVM
        return cell
    }
}

//MARK: - TableView Delegate
extension WishlistView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(AlertMessage.tryDeleteSwipe, title: AlertMessage.notAllowed)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title: AlertMessage.warning, message: AlertMessage.deleteConfrimMessage, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: AlertMessage.cancel, style: .cancel, handler: nil)
            let confirmAction = UIAlertAction(title: AlertMessage.Confirm, style: .destructive) { [weak self] action in
                guard let self = self else { return }
                self.viewModel.removeFromFavourites(index: indexPath)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
            present(alertController, animated: true)
        }
    }
}
