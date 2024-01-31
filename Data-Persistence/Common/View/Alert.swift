//
//  Alert.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 16/01/2024.
//

import UIKit

struct Alert {
    private init(){}
    static func showAlert(target: UIViewController, title: String, message: String, actions: [UIAlertAction]? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            guard let actions = actions else {
                alert.addAction(UIAlertAction(title: "Close", style: .destructive))
                return
            }
            for action in actions {
                alert.addAction(action)
            }
            target.present(alert, animated: true)
        }
    }
}
