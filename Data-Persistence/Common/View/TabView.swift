//
//  TabView.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 12/01/2024.
//

import UIKit

class TabView: UITabBarController {
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setNeedsLayout()
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Setup Tabs
    private func setUpTabs(){
        let homeViewController = HomeView()
        let categoryViewController = CategoryView()
        let userProfileViewController = UserProfileView()
        let wishlistViewController = WishlistView()
        let shoppingCartView = ShoppingCartView()
        
        homeViewController.title = "Home"
        categoryViewController.title = "Category"
        userProfileViewController.title = "Me"
        wishlistViewController.title = "Wishlist"
        shoppingCartView.title = "Cart"

        let homeNavController = UINavigationController(rootViewController: homeViewController)
        let wishListNavController = UINavigationController(rootViewController: wishlistViewController)
        let categoryNavController = UINavigationController(rootViewController: categoryViewController)
        let userProfileNavController = UINavigationController(rootViewController: userProfileViewController)
        let shoppingCartNavController = UINavigationController(rootViewController: shoppingCartView)

        // Set the view controllers for the tab bar controller
        self.setViewControllers([homeNavController, categoryNavController, shoppingCartNavController, wishListNavController, userProfileNavController], animated: true)
                                        
        guard let items = self.tabBar.items else {return}
        let images = ["house", "square.grid.2x2","cart","heart","person.crop.circle"]
        
        for i in 0...4 {
            items[i].image = UIImage(systemName: images[i])
        }
        
        self.tabBar.tintColor = .label
        let selectedColor = UIColor(hex: "#F4F4F4FF")
        self.tabBar.backgroundColor = selectedColor
        self.tabBar.unselectedItemTintColor = .gray
    }
}
