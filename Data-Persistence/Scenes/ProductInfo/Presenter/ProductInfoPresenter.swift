//
//  ProductInfoPresenter.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 24/01/2024.
//

import Foundation

class ProductInfoPresenter {
    private weak var view: ProductInfoProtocol?
    private var product: Product?
    private var dataBaseManager: DataBaseManagerProtocol
    
    
    init(view: ProductInfoProtocol? = nil, product: Product?, dataBaseManager: DataBaseManagerProtocol = CoreDataManager.shared) {
        self.view = view
        self.product = product
        self.dataBaseManager = dataBaseManager
    }
    
    func viewDidLoad() {
    }
    
    // MARK: - Configure Cell
    func configureCell(cell: ProductCellProtocol, for index: Int) {
        let imageUrl = product?.images?[index].src ?? ""
        cell.displayImage(by: imageUrl)
    }
    
    func updateProductImage(for index: Int) {
        let imageUrl = product?.images?[index].src
        view?.updateProductImage(imageUrl)
    }
    
    func getItemsCount() -> Int {
        guard let count = product?.images?.count else { return 1 }
        return count
    }
    
    func isProductFavourite() -> Bool {
        guard let isFav = product?.isFavourite else { return false }
        return isFav
    }
    
}
