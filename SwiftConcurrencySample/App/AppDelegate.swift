//
//  AppDelegate.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/10.
//

import Foundation
import UIKit
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()

//        let rootViewController = SearchRepositoryBuilder.build(
//            apiClient: APIClient(
//                urlSession: URLSession.shared,
//                envClient: ENVClient()
//            ),
//            userDefaultsClient: UserDefaultsClient(userDefaults: UserDefaults.standard)
//        )
//        let navigationController = UINavigationController(rootViewController: rootViewController)
        
//        let tabbarController = UITabBarController()
//        tabbarController.setViewControllers([navigationController, UIViewController()], animated: false)
        
        let tabbarController = BaseTabBarController(
            apiClient: APIClient(
                urlSession: URLSession.shared,
                envClient: ENVClient()
            ),
            userDefaultsClient: UserDefaultsClient(
                userDefaults: UserDefaults.standard
            )
        )

        window?.rootViewController = tabbarController
        window?.makeKeyAndVisible()
        return true
    }
}
