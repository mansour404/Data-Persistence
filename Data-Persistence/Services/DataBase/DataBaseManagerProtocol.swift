//
//  DataBaseManagerProtocol.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 15/01/2024.
//

import Foundation


// MARK: - CoreData Protocol
protocol DataBaseManagerProtocol {
    func insertProduct(_ item: ProductModelDB)
    func fetchProducts(completion: @escaping(Result<[ProductModelDB], Error>) -> Void)
    func removeALLProducts()
    func updateProduct(by id: Int, isFavourite: Bool)
}
