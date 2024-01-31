//
//  ViewModelTwo.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 27/01/2024.
//

import Foundation

class HomeViewModel {
    private let networkManager: NetworkManagerProtocol
    private let dataBaseManager: DataBaseManagerProtocol
    private let helper: Helper = Helper()

    // MARK: Init
    init(networkManager: NetworkManager = NetworkManager.shared, dataBaseManager: DataBaseManagerProtocol = CoreDataManager.shared) {
        self.networkManager = networkManager
        self.dataBaseManager = dataBaseManager
    }
    
    private var cellViewModels: [ProductModelDB] = [ProductModelDB]() {
        didSet {
            reloadCollectionViewClosure?()
            updateLabelClosure?("\(numberOfItems) products Found")
        }
    }
    
    private var filteredCellViewModels: [ProductModelDB] = [ProductModelDB]() {
        didSet {
            reloadCollectionViewClosure?()
            updateLabelClosure?("\(numberOfItems) products Found")
        }
    }
    
    // MARK: Closures
    var reloadCollectionViewClosure: (() -> ())?
    var showAlertClosure: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    var updateLabelClosure: ((String) -> ())?
    
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
        return isSearching ? filteredCellViewModels.count : cellViewModels.count
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> ProductModelDB {
        return isSearching ? filteredCellViewModels[indexPath.item] : cellViewModels[indexPath.item]
    }
    
    var isSearching: Bool = false
    
    // MARK: Dispatch Queue & Group
    private let queueOne = DispatchQueue(label: "queueOne")
    private let queueTwo = DispatchQueue(label: "queueTwo")
    private let dispatchGroup = DispatchGroup()
    
    // MARK: Cashing & Filter
    private var productsFromDB: [Product] = []
    private var productsFromAPI: [Product] = []
    private var filteredProducts = [Product]()
    private var favouriteListId = [Int]()
    private var products = [Product]()
    
    private var sendedId: Int?
    private var sendedState: Bool = false
}

// MARK: - GCD Implementation
extension HomeViewModel {
    
    // MARK: initFetch()
    func initFetch() {
        state = .loading
        fetchProductsFromDB()
        fetchProductsFromAPI()
        compareApiAndCoreData()
        // Notification
        setupNotification()
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
                    self.productsFromDB = products.map { productModelDB in
                        let image = productModelDB.imageText.map { Image(src: $0) }
                        productModelDB.imageTextArray.map { arr in
                            let two = arr.map { imageUrl in Image(src: imageUrl)}
                            images = two
                        }
                        return Product(id: productModelDB.id, title: productModelDB.title, vendor: productModelDB.vendor, bodyHtml: productModelDB.bodyHtml, image: image, images: images, variants: [Variants(price: productModelDB.price)], isFavourite: productModelDB.isFavourite)
                    }
                    
                    self.favouriteListId = productsFromDB.filter{ $0.isFavourite == true }.map{ $0.id ?? 0}
                    print("Data Fetched from data base")
                    print(" 1: dispatchGroup leave")
                    dispatchGroup.leave() // Leave after finished
                case .failure(let error):
                    print("error from fetchAllProductsFromDB", error)
                    self.productsFromDB = []
                    self.alertMessage = error.localizedDescription // Alert controller will be present
                    // MARK: Leave after finished
                    print(" 1: dispatchGroup leave")
                    dispatchGroup.leave() // Leave if fail
                }
            }
        }
    }
    
    private func fetchProductsFromAPI() {
        // MARK: Enter dispatchGroup
        dispatchGroup.enter()
        print(" 2: dispatchGroup enter")
        queueTwo.async { [weak self] in
            guard let self else { return }
            self.networkManager.fetchHomeData { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let products):
                    print("Data Fetched from API")
                    guard let products = products else { return }
                    self.productsFromAPI = products
                    self.dispatchGroup.leave() // Leave after finished
                    print(" 2: dispatchGroup leave")
                case .failure(let error):
                    print("error from: fetchProductsFromAPI", error)
                    self.productsFromAPI = []
                    self.alertMessage = error.localizedDescription // Alert controller will be present
                    // MARK: Leave after finished
                    print(" 2: dispatchGroup leave")
                    self.dispatchGroup.leave() // Leave if fail
                }
            }
        }
    }
    
    private func compareApiAndCoreData() {
        dispatchGroup.notify(queue: .main) { [weak self] in
            print(" 3: dispatchGroup main notify")
            guard let self else { return }
            if self.productsFromAPI.isEmpty && self.productsFromDB.isEmpty {
                self.state = .empty
                self.alertMessage = AlertMessage.noData
            } else if self.productsFromAPI.isEmpty { // process data from core data
                processFetchedProduct(products: self.productsFromDB)
                self.state = .populated // change state to stop animation
                print("Data Loaded from Core Data")
            } else { // process data from API
                self.productsFromAPI.mapInPlace { if self.favouriteListId.contains($0.id ?? 0) { $0.isFavourite = true } else { $0.isFavourite = false } }
                processFetchedProduct(products: productsFromAPI)
                dataBaseManager.removeALLProducts()
                
                // MARK: - Helper run in back ground thread.
                helper.insertDecodedImagesIntoDataBase(from: productsFromAPI)
                self.state = .populated // change state to stop animation
                print("Data Loaded from API")
            }
        }
    }

    
    // MARK: 1- Called inside initFetch()
    private func processFetchedProduct(products: [Product]) {
        self.products = products // Caching
        self.filteredProducts = products // Caching
        
        var vms = [ProductModelDB]()
        var filteredVms = [ProductModelDB]()
        for product in products {
            
            // Call creatCellViewMdoel(product: Product)
            vms.append(creatCellViewMdoel(product: product))
            filteredVms.append(creatCellViewMdoel(product: product))
        }
        self.cellViewModels = vms
        self.filteredCellViewModels = filteredVms
    }
    
    // MARK: 2- Called inside processFetchedProduct(products: [Product])
    private func creatCellViewMdoel(product: Product) -> ProductModelDB {
        return ProductModelDB(product: product)
    }
   
}


// MARK: - Search
extension HomeViewModel {
    func searchProduct(searchText: String) {
        print(searchText)
        let text = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        if text.isEmpty || text == "" {
            isSearching = false
            processFetchedProduct(products: products)
        } else {
            isSearching = true
            // MARK: Search by vendor
            filteredProducts = products.filter({ $0.vendor?.lowercased().contains(text) ?? false })
            print(filteredProducts.count)
            updateFilteredCellViewModels(products: filteredProducts)
        }
    }
    
    func getFilteredProduct(at index: IndexPath) -> Product {
        return filteredProducts[index.item]
    }
    
    
    private func updateFilteredCellViewModels(products: [Product]) {
        var vms = [ProductModelDB]()
        for product in products {
            vms.append(creatCellViewMdoel(product: product))
        }
        self.filteredCellViewModels = vms
    }
    
}

// MARK: - Favourits
extension HomeViewModel: DataPreferences {
    func addToFavourites(id: Int?) {
        updateDataSources(at: id, state: true)
    }
    
    func removeFromFavourites(id: Int?) {
        //updateDataSources(at: id, state: false)
        self.sendedId = id
        self.sendedState = false
        alertMessage = AlertMessage.deleteConfrimMessage
    }
    
    func removeFromFavForOtherVCs(id: Int?) {
        // No need to Present Alert
        // Because i want to present action sheet alert in wishlist view controller
        updateDataSources(at: id, state: false)
    }
    
    func runConfirmAction() {
        updateDataSources(at: sendedId, state: sendedState)
    }
    
    private func updateDataSources(at productID: Int?, state isFavourite: Bool) {
        guard let id = productID else { return }
        productsFromDB.mapInPlace { if $0.id == id { $0.isFavourite = isFavourite } }
        productsFromAPI.mapInPlace { if $0.id == id { $0.isFavourite = isFavourite } }
        cellViewModels.mapInPlace { if $0.id == id { $0.isFavourite = isFavourite } }
        filteredCellViewModels.mapInPlace { if $0.id == id { $0.isFavourite = isFavourite } }
        products.mapInPlace { if $0.id == id { $0.isFavourite = isFavourite } }
        filteredProducts.mapInPlace { if $0.id == id { $0.isFavourite = isFavourite } }
        updateList(id: id)
        
        // MARK: - Update the product in DB
        dataBaseManager.updateProduct(by: id, isFavourite: isFavourite)
    }
    
    private func updateList(id: Int) {
        if favouriteListId.contains(id) {
            favouriteListId = favouriteListId.filter(){$0 != id}
        } else {
            favouriteListId.append(id)
        }
        print(favouriteListId)
    }
}


// MARK: - Notification Center
extension HomeViewModel {
    
    private func setupNotification() {
        // step 2 notification: add observer for listening to notifcation
        NotificationCenter.default.addObserver(self, selector: #selector(listenToNotification), name: NSNotification.Name(NotificationName.notifyUpdate), object: nil)
    }
    
    @objc func listenToNotification(notification: Notification) {
        let wishlistViewModel = notification.object as? WishlistViewModel
        let backedProductId = wishlistViewModel?.backProductId
        removeFromFavForOtherVCs(id: backedProductId)
        //removeFromFavourites(id: backedProductId)
    }
}

