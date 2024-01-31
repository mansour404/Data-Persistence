//
//  ProductModel.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 12/01/2024.
//

import Foundation

// MARK: - Response
struct ProductsResponse: Codable {
    var products: [Product]
}

// MARK: - Response
struct MyProductcontainer : Codable{
    var product : Product
}

// MARK: - Response
struct Product : Codable {
    
    var id : Int?
    var title : String?
    var vendor : String?
    var bodyHtml : String?
    var image: Image?
    var images : [Image]?
    var variants : [Variants]?
    var isFavourite: Bool?

    private enum CodingKeys: String, CodingKey {
        case id, title, vendor, images, variants, image
        case bodyHtml = "body_html"
    }
}

// MARK: - Variants
struct Variants : Codable {
    var price: String?
    var inventoryQuantity: Int?
    
    private enum CodingKeys: String, CodingKey {
        case price
        case inventoryQuantity = "inventory_quantity"
    }
}

// MARK: - Image
struct Image: Codable {
    let src: String?
}

