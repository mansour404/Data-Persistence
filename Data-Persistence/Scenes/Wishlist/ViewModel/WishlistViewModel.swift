//
//  WishlistPresenter.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 28/01/2024.
//

import Foundation

class WishlistViewModel {
    private let dataBaseManager: DataBaseManagerProtocol
    
    // MARK: Init
    init(dataBaseManager: DataBaseManagerProtocol = CoreDataManager.shared) {
        self.dataBaseManager = dataBaseManager
    }
    
    private var cellViewModels: [ProductModelDB] = [ProductModelDB]() {
        didSet {
            reloadTableViewClosure?()
            updateLabelClosure?("\(numberOfItems) products Found")
        }
    }
    
    // MARK: Closures
    var reloadTableViewClosure: (() -> ())?
    var showAlertClosure: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    var updateLabelClosure: ((String) -> ())?
    var showAnimationClosure: (() -> ())?
    
    // MARK: Callbacks for interface
    var state: State = .empty {
        didSet {
            updateLoadingStatus?()
        }
    }
    
    var alertMessage: String? {
        didSet {
            showAlertClosure?()
        }
    }
    
    var numberOfItems: Int {
        return cellViewModels.count
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> ProductModelDB {
        return cellViewModels[indexPath.row]
    }
    
    func getProduct(at index: IndexPath) -> Product {
        return products[index.item]
    }
    
    // MARK: Dispatch Queue & Group
    private let queueOne = DispatchQueue(label: "queueOne")
    private let dispatchGroup = DispatchGroup()
    
    // MARK: Cashing & Filter
    private var productsFromDB: [Product] = []
    private var favouriteListId = [Int]()
    private var products = [Product]()
    var backProductId: Int?
}

// MARK: - GCD Implementation
extension WishlistViewModel {
    
    // MARK: initFetch()
    func initFetch () {
        state = .loading
        fetchProductsFromDB()
        chekcCoreDataResult()
    }
    
    private func fetchProductsFromDB() {
        // MARK: Enter dispatchGroup
        dispatchGroup.enter() // Enter dispatch group
        print(" 1: dispatchGroup enter")
        queueOne.async { [weak self] in
            guard let self else { return }
            self.dataBaseManager.fetchProducts { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let products):
                    var images: [Image] = []
                    self.productsFromDB = products.filter{ $0.isFavourite == true }.map { productModelDB in
                        let image = productModelDB.imageText.map { Image(src: $0) }
                        productModelDB.imageTextArray.map { arr in
                            images = arr.map { imageUrl in Image(src: imageUrl)}
                        }
                        return Product(id: productModelDB.id, title: productModelDB.title, vendor: productModelDB.vendor, bodyHtml: productModelDB.bodyHtml, image: image, images: images, variants: [Variants(price: productModelDB.price)], isFavourite: productModelDB.isFavourite)
                    }
                    self.favouriteListId = productsFromDB.map{ $0.id ?? 0}
                    print(" 1: dispatchGroup leave")
                    self.state = .populated
                    dispatchGroup.leave() // Leave after finished
                case .failure(let error):
                    self.productsFromDB = []
                    self.alertMessage = error.localizedDescription // Alert controller will be present, show alert Controller
                    // MARK: Leave after finished
                    print(" 1: dispatchGroup leave")
                    self.state = .empty
                    dispatchGroup.leave() // Leave if fail
                }
            }
        }
    }
    
    
    private func chekcCoreDataResult() {
        dispatchGroup.notify(queue: .main) { [weak self] in
            print(" 3: dispatchGroup main notify")
            guard let self else { return }
            if self.productsFromDB.isEmpty { // process data from core data
                self.alertMessage = AlertMessage.wishlistEmpty
                self.state = .empty // change state to stop animation
            } else {
                processFetchedProduct(products: self.productsFromDB)
                self.state = .populated // change state to stop animation
            }
        }
    }

    
    // MARK: 1- Called inside initFetch()
    private func processFetchedProduct(products: [Product]) {
        self.products = products // Caching
        
        var vms = [ProductModelDB]()
        for product in products {
            // Call creatCellViewMdoel(product: Product)
            vms.append(creatCellViewMdoel(product: product))
        }
        self.cellViewModels = vms
    }
    
    // MARK: 2- Called inside processFetchedProduct(products: [Product])
    private func creatCellViewMdoel(product: Product) -> ProductModelDB {
        return ProductModelDB(product: product)
    }
   
}

// MARK: - Favourits
extension WishlistViewModel {
    
    func removeFromFavourites(index: IndexPath) {
        let id = products[index.row].id
        self.backProductId = id
        // MARK: Post Notification
        postNotification()
        updateDataSources(at: id, state: false)

    }
    
    private func updateDataSources(at productID: Int?, state isFavourite: Bool) {
        guard let id = productID else { return }
        cellViewModels = cellViewModels.filter { $0.id != id }
        productsFromDB = productsFromDB.filter { $0.id != id }
        products = products.filter { $0.id != id }
        updateList(id: id)
        // MARK: Update the product in DB
        // Not needed any more HomeViewModel will do it.
        //dataBaseManager.updateProduct(by: id, isFavourite: isFavourite)
    }
    
    private func updateList(id: Int) {
        favouriteListId = favouriteListId.filter(){$0 != id}
        print(favouriteListId)
    }
    
    //MARK: - NotificationCenter
    private func postNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(NotificationName.notifyUpdate), object: self)
    }
}

