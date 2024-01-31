//
//  UITableViewCell + Identifier.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 28/01/2024.
//

import UIKit

extension UITableViewCell {
    static var identifier: String {
        return String(describing: Self.self)
    }
}
