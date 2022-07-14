//
//  BaseTabBarController.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/13.
//

import Foundation
import UIKit

class BaseTabBarController: UITabBarController {
    private let featureProvider: FeatureProviderProtocol
    
    init(
        featureProvider: FeatureProviderProtocol
    ) {
        self.featureProvider = featureProvider
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
        let searchRepositoryViewRequest = SearchRepositoryViewRequest()
        let searchRepoVc = featureProvider.build(searchRepositoryViewRequest)
        let firstNavigationController = UINavigationController(rootViewController: searchRepoVc)
        searchRepoVc.setupTabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass")
        )

        let staredRepositoryViewRequest = StaredRepositoryViewRequest()
        let staredRepoVc = featureProvider.build(staredRepositoryViewRequest)
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
