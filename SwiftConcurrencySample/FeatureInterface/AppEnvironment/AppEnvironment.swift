//
//  File.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/14.
//

import Foundation

/// FeatureProviderMock時にはそれぞれのenvironmentMockをDIしたものをDI
class AppEnvironment {
    let apiClient: APIClientProtocol
    let envClinet: ENVClientProtocol
    let userDefaultsClient: UserDefaultsClientProtocol
    let notificationCenter: NotificationCenter
    
    init(
        apiClient: APIClientProtocol,
        envClinet: ENVClientProtocol,
        userDefaultsClient: UserDefaultsClientProtocol,
        notificationCenter: NotificationCenter
    ) {
        self.apiClient = apiClient
        self.envClinet = envClinet
        self.userDefaultsClient = userDefaultsClient
        self.notificationCenter = notificationCenter
    }
}
