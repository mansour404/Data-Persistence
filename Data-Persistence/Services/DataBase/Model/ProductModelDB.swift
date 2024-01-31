//
//  ProductModelDB.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 15/01/2024.
//

import Foundation

struct ProductModelDB {
    let id: Int?
    let vendor: String?
    let title: String?
    var imageData: Data?
    let imageText: String?
    let bodyHtml: String?
    let price: String?
    let inventoryQuantity: Int?
    var isFavourite: Bool?
    let imageTextArray: [String]?
    var imageDataArray: [Data]?
    
    init(product: Product) {
        vendor = product.vendor
        bodyHtml = product.bodyHtml
        price = product.variants?.first?.price
        imageText = product.image?.src
        id = product.id
        title = product.title
        isFavourite = product.isFavourite
        inventoryQuantity = product.variants?.first?.inventoryQuantity
        imageTextArray = product.images?.compactMap{ $0.src }
    }
    
    init(product: Product, imageData: Data?, imageDataArray: [Data]?) {
        self.init(product: product)
        self.imageData = imageData
        self.imageDataArray = imageDataArray
    }
    
    init(productDB: ProductDB) {
        self.id = Int(productDB.id)
        self.vendor = productDB.vendor
        self.title = productDB.title
        self.imageText = productDB.imageText
        self.bodyHtml = productDB.bodyHtml
        self.price = productDB.price
        self.inventoryQuantity = Int(productDB.inventoryQuantity)
        self.isFavourite = productDB.isFavourite
        self.imageTextArray = productDB.imageTextArray
        self.imageData = productDB.imageData
        self.imageDataArray = productDB.imageDataArray
    }
    
}
