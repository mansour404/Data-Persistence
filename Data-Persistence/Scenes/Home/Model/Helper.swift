//
//  Helper.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 19/01/2024.
//

import UIKit

class Helper {
    private var imageData: Data?
    private var imageDataArray: [Data]? = []
    private let dbManager = CoreDataManager.shared
    // MARK: Dispatch Group
    private let dispatchGroup = DispatchGroup()

    func insertDecodedImagesIntoDataBase(from products: [Product]) {
        for product in products {
            var dbObject = ProductModelDB(product: product, imageData: nil, imageDataArray: [])
            
            // MARK: 1- Download main image
            dispatchGroup.enter()
            decodeImage(product.image?.src) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let data):
                    imageData = data
                    dbObject.imageData = data
                    dispatchGroup.leave()
                case .failure(let error):
                    print(error)
                    dispatchGroup.leave()
                }
            }
            
            // MARK: 2- Download other images
            guard let images = product.images else { return }
            for image in images {
                dispatchGroup.enter()
                decodeImage(image.src) {  [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let data):
                        guard let data = data else { return }
                        imageDataArray?.append(data)
                        dbObject.imageDataArray?.append(data)
                        dispatchGroup.leave()
                    case .failure(let error):
                        print(error)
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) { [weak self] in
                guard let self else { return }
                // MARK: 3- insert
                self.dbManager.insertProduct(dbObject)
            }
        }
    }
        
    
    
    private func decodeImage(_ stringUrl: String?, completion: @escaping(Result<Data?, Error>) -> Void) {
        UIImageView().downloadImage(from: stringUrl, placeHolder: "BlankPng") { result in
            switch result {
            case.success(let image):
                guard let data = image?.pngData() else { return }
                //data = image.jpegData(compressionQuality: 0.5)
                completion(.success(data))
            case.failure(let error):
                completion(.failure(error))
            }
        }
    }
}

