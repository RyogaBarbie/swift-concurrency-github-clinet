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


        /// initialize

        let envClient = ENVClient()
        let featureProvider = FeatureProvider(
            appEnvironment: .init(
                apiClient: APIClient(
                    urlSession: URLSession.shared,
                    envClient: envClient
                ),
                envClinet: envClient,
                userDefaultsClient: UserDefaultsClient(
                    userDefaults: UserDefaults.standard
                )
            )
        )
        
        let tabbarController = BaseTabBarController(
            featureProvider: featureProvider
        )

        window?.rootViewController = tabbarController
        window?.makeKeyAndVisible()
        return true
    }
}
