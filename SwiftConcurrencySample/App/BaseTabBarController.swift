//
//  BaseTabBarController.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/13.
//

import Foundation
import UIKit

class BaseTabBarController: UITabBarController {
    let apiClient: APIClientProtocol
    let userDefaultsClient: UserDefaultsClientProtocol
    
    init(
        apiClient: APIClientProtocol,
        userDefaultsClient: UserDefaultsClientProtocol
    ) {
        self.apiClient = apiClient
        self.userDefaultsClient = userDefaultsClient
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        let searchRepoVc = SearchRepositoryBuilder.build(
            apiClient: apiClient,
            userDefaultsClient: userDefaultsClient
        )
        let firstNavigationController = UINavigationController(rootViewController: searchRepoVc)
        searchRepoVc.setupTabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass")
        )

        let staredRepoVc = StaredRepositoryBuilder.build(
            apiClient: apiClient,
            userDefaultsClient: userDefaultsClient
        )
        staredRepoVc.setupTabBarItem(
            title: "Stared",
            image: UIImage(systemName: "star.fill")
        )
        let secondNavigationController = UINavigationController(rootViewController: staredRepoVc)
        
        setViewControllers(
            [firstNavigationController, secondNavigationController],
            animated: false
        )
    }
}
