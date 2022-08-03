//
//  FeatureProvider.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/14.
//

import Foundation
import UIKit

@MainActor
class FeatureProvider: FeatureProviderProtocol {
    private let appEnvironment: AppEnvironment
    
    init(
        appEnvironment: AppEnvironment
    ) {
        self.appEnvironment = appEnvironment
    }
    
    func build(_: SearchRepositoryViewRequest) -> UIViewController {
        SearchRepositoryBuilder.build(
            apiClient: appEnvironment.apiClient,
            userDefaultsClient: appEnvironment.userDefaultsClient,
            notificationCenter: appEnvironment.notificationCenter
        )
    }
    
    func build(_: StaredRepositoryViewRequest) -> UIViewController {
        StaredRepositoryBuilder.build(
            apiClient: appEnvironment.apiClient,
            userDefaultsClient: appEnvironment.userDefaultsClient,
            notificationCenter: appEnvironment.notificationCenter
        )
    }
}
