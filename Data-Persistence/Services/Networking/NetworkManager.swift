//
//  NetworkManager.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 12/01/2024.
//

import Foundation
import Alamofire

// MARK: - Network protocol
protocol NetworkManagerProtocol {
    func fetchHomeData(completion: @escaping (Result<[Product]?, Error>) -> Void)
}

// MARK: - Network manager
class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()
    private init() {}
    private let headerApi: HTTPHeaders = [
        "X-Shopify-Access-Token": "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",
        "Content-Type": "application/json"
    ]
    
    //MARK: - Fetching Data From Api to catagory
    func fetchHomeData(completion: @escaping (Result<[Product]?, Error>) -> Void) {
        let url = "https://a6cdf13b3aee85b07964a84ccc1bd762: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@ios-q1-new-capital-admin2-2023.myshopify.com/admin/api/2023-10/products.json"
        AF.request(url).validate().responseDecodable(of: ProductsResponse.self) { response in
            switch response.result {
            case .success(let decodedData):
                //print(String(data: response.data!, encoding: .utf8))
                completion(.success(decodedData.products))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

