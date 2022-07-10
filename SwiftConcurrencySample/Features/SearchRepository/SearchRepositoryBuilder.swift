//
//  SearchRepositoryBuilder.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/10.
//

import Foundation
import UIKit

enum SearchRepositoryBuilder {
    @MainActor static func build(
        apiClient: APIClientProtocol,
        userDefaultsClient: UserDefaultsClientProtocol
    ) -> UIViewController {
        let viewModel = SearchRepositoryViewModel(
            state: .init(repositories: []),
            environment: .init(
                apiClient: apiClient,
                userDefaultsClient: userDefaultsClient
            )
        )
        let view = SearchRepositoryView(viewModel: viewModel)
        let vc = SearchRepositoryHostingController(
            view,
            viewModel: viewModel
        )
        return vc
    }
}
