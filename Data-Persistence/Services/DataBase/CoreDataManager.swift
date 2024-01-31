//
//  CoreDataManager.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 15/01/2024.
//

import UIKit
import CoreData


// MARK: - CoreData manager
final class CoreDataManager: DataBaseManagerProtocol {
    
    // MARK: - Variables
    var context: NSManagedObjectContext!
    private var items: [ProductModelDB]  = []
    
    // MARK: - Singletone instance
    static let shared: CoreDataManager = CoreDataManager()
    
    // MARK: - Initializer
    private init() {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Insert product
    func insertProduct(_ item: ProductModelDB) {
        let product = NSEntityDescription.insertNewObject(forEntityName: "ProductDB", into: context) as! ProductDB
        product.id = Int64(item.id ?? 0)
        product.bodyHtml = item.bodyHtml
        product.title = item.title
        product.vendor = item.vendor
        product.price = item.price
        product.isFavourite = item.isFavourite ?? false
        product.inventoryQuantity = Int32(item.inventoryQuantity ?? 0)
        product.imageText = item.imageText // Save String
        product.imageData = item.imageData // Save image
        product.imageTextArray = item.imageTextArray // Save string array
        product.imageDataArray = item.imageDataArray // Save image array
        context.insert(product)
        do {
            try context.save()  // save after insert
            print("insert Successfully", item.isFavourite ?? "")
        } catch {
            print(error)
        }
    }
    
    // MARK: - Fetch all products
    func fetchProducts(completion: @escaping(Result<[ProductModelDB], Error>) -> Void) {
        let fetchRequest = ProductDB.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false // prevent => data: <fault> ERROR
        do {
            let result = try context.fetch(fetchRequest)
            items = [] // Remove before append on items
            items = result.map{ ProductModelDB(productDB: $0)}
            print("fetch successfully \(items.count) product")
            
            completion(.success(items))
        } catch {
            print(error)
            completion(.failure(error))
        }
    }
    
    // MARK: - Update single product
    func updateProduct(by id: Int, isFavourite: Bool) {
        let fetchRequest = ProductDB.fetchRequest()
        let predicate = NSPredicate(format: "id='\(id)'")
        fetchRequest.predicate = predicate
        do{
            let results = try context.fetch(fetchRequest)
            results.first?.isFavourite = isFavourite
            try context.save()
            print("Update product successfully")
        } catch {
            print (error)
        }
    }
    
    // MARK: - Remove all products
    func removeALLProducts() {
        let fetchRequest = ProductDB.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            for singleProduct in result {
                context.delete(singleProduct)  // Row by row
            }
            try context.save()
            print("remove all successfully \(result.count)")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Fetch single product
    func fetchSingleProduct(productId: Int, completion: (Result<ProductModelDB, Error>) -> Void) {
        //let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let fetchRequest = ProductDB.fetchRequest()
        let predicate = NSPredicate(format: "id='\(productId)'")

        fetchRequest.predicate = predicate
        do {
            let result = try context.fetch(fetchRequest)
            guard let fetchedProduct = result.first else { return }
            let product = ProductModelDB(productDB: fetchedProduct)
            print("Fetch single product successfully")
            completion(.success(product))
        } catch {
            print(error)
            completion(.failure(error))
        }
    }
    
    // MARK: - Is Favorite
    func isFavorite(productId: Int) -> Bool {
        let fetchRequest = ProductDB.fetchRequest()
        let predicate = NSPredicate(format: "id='\(productId)'")
        fetchRequest.predicate = predicate
        
        do {
            let result = try context.fetch(fetchRequest) // array
            let firstProduct = result.first // first element in array
            guard let isFav = firstProduct?.isFavourite else { return false }
            return isFav
        }
        catch {
            print(error.localizedDescription)
        }
        return false
    }
}
