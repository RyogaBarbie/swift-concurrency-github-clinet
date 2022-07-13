//
//  BaseTabBarController.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/13.
//

import Foundation
import UIKit

class BaseTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        let searchRepoVc = SearchRepositoryBuilder.build(
            apiClient: APIClient(
                urlSession: URLSession.shared,
                envClient: ENVClient()
            ),
            userDefaultsClient: UserDefaultsClient(userDefaults: UserDefaults.standard)
        )
        let navigationController = UINavigationController(rootViewController: searchRepoVc)
        
        searchRepoVc.setupTabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass")
        )

        let vc = UIViewController()
        vc.setupTabBarItem(
            title: "Stared",
            image: UIImage(systemName: "star.fill")
        )
        
        setViewControllers([navigationController, vc], animated: false)
    }
}
