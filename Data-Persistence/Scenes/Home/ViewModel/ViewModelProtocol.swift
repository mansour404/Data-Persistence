//
//  ViewModelProtocol.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 22/01/2024.
//

import Foundation

protocol DataProviding {
    var data: [Product] { get }
    var filteredData: [Product] { get }
    func filterData(with searchText: String)
}

protocol DataObserving {
    var dataDidChange: (([Product]) -> Void)? { get set }
    var filteredDataDidChange: (([Product]) -> Void)? { get set }
}

protocol DataPreferences: AnyObject {
    func addToFavourites(id: Int?)
    func removeFromFavourites(id: Int?)
}
